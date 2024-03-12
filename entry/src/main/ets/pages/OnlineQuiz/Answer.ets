import router from '@ohos.router'
import { Constants } from '../../common/Constants'
import OptionItem from './QuizOptionItem'
import AnswerSheetDialog from './AnswerSheetDialog'
import DatabaseHelper from '../../services/DatabaseHelper';
import { chapqa } from '../../models/chapqa';
import { AgUser } from '../../services/Auth'
import { chaplog } from '../../models/chaplog'
import Prompt from '@system.prompt'
import { chapqalog } from '../../models/chapqalog'
import AnswerOptionItem from './AnswerOptionItem'

interface IAnswer {
  letter: string,  // 答案标记，A，B等
  txt: string, // 答案选项
  isselected: boolean,  // 用户是否选择了此项答案
  qtype:string  // 题目类型：单选/判断/多选
}

class Answer implements IAnswer {
  letter: string
  txt: string
  isselected: boolean
  qtype:string

  constructor(answer: IAnswer) {
    this.letter = answer.letter;
    this.txt = answer.txt;
    this.isselected = answer.isselected;
    this.qtype = answer.qtype;
  }
}

class ParamsType {
  id: number
  currentIndex:number
}

@Entry
@Component
struct AnswerIndex {
  @State qaList: chapqa[] = [new chapqa()]; // 题目列表
  @State answerList: Answer[] = [new Answer({ letter: 'A', txt: '', isselected: false,qtype:'单选' })]; // 答案选项
  @State totalCout: number = 0; //总题量
  @State currentIndex: number = 0; //当前题目索引号
  @State currentQA: chapqa = new chapqa(); //当前题目
  private cid = 0; // 当前考卷id
  @State userAnswerChars: string[] = []; //当前题目用户选择的答案标记：例如A,B等
  @StorageLink('user') currentUser: AgUser = new AgUser();
  private _userSelectedAwser: chapqalog[] = [];

  async aboutToAppear() {
    try {
      // 获取参数
      let params: ParamsType = router.getParams() as ParamsType;
      this.cid = params.id;
      this.currentIndex =params.currentIndex;

      //获取当前试卷所有的题目
      let list = await DatabaseHelper.QuizList_Query(this.cid);
      console.log('answer aboutToAppear->',this.cid,this.currentIndex,list.length);
      if (list && list.length > 0) {
        this.qaList = list;
        this.totalCout = list.length;

        // 获取用户在当前试卷中的所有的答题数据
        this._userSelectedAwser = await DatabaseHelper.ChapQALog_Query_User_Select_Answer1(this.cid, this.currentUser.uid.toString());

        //初始化当前题目选项，并设置选择状态
        await this.initCurrentQA();
      }

    } catch (err) {
      console.log('QuizIndex.ets aboutToAppear error', JSON.stringify(err));
    }
  }


  async initCurrentQA() {
    try{

    this.currentQA = this.qaList[this.currentIndex];
    //答案选项文字数组
    let answerArr: string[] = JSON.parse(this.currentQA.answer) as string[];
    //答案选项数组
    let letterArr: string[] = JSON.parse(this.currentQA.letter) as string[];

    // 获取用户选择的当前题目答案begin
    let userAswers = []; // 用户针对当前题目做的答案
    let _qalog = new chapqalog();
      console.log('_qalog',this._userSelectedAwser.length);

    if (this._userSelectedAwser.length > 0) {
      _qalog = this._userSelectedAwser.find(item => item.cqaid === this.currentQA.cqaid);

      userAswers = _qalog ? JSON.parse(_qalog.userAnswer) : []; //["A","B"]
    }
    this.userAnswerChars = userAswers;
    console.log('userAswers->',userAswers.join().toString());

    // 获取用户选择的当前题目答案end
    let awlist = [];
    answerArr.forEach((item: string, index: number) => {
      awlist.push(
        new Answer({ letter: letterArr[index], txt: item, isselected: userAswers.includes(letterArr[index])
        ,qtype:this.currentQA.qtype })
      )
    })

    this.answerList = awlist;

    }catch (err){
      console.log('Answer initCurrentQA->',JSON.stringify(err));
    }
  }

  build() {
    Column() {
      Column() {

        // 顶部
        Stack({ alignContent: Alignment.End }) {
          Text('答案解析')
            .width('100%')
            .fontSize(18)
            .fontWeight(600)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 10, bottom: 20, })

        // 进度条
        Row() {
          Progress({ value: this.currentIndex + 1, total: this.totalCout })
            .margin({ right: 10 })
            .layoutWeight(1)
          Text() {
            Span((this.currentIndex + 1).toString())
              .fontWeight(900)
              .fontColor(Color.Gray)
            Span(`/${this.totalCout.toString()}`)
              .fontWeight(900)
              .fontColor('#c4c4c4')
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 题目类型
        Row() {
          Text(this.currentQA.qtype)
            .fontSize(12)
            .fontColor(Color.Gray)
            .padding({ top: 2, bottom: 2, left: 10, right: 10 })
            .backgroundColor(Color.White)
        }
        .width('100%')

        // 题目答案
        Column({ space: 16 }) {
          Text(this.currentQA.title)
            .width('100%')
          Column({ space: 8 }) {
            ForEach(this.answerList, (item: Answer, index: number) => {
              AnswerOptionItem({
                label: `${item.txt}`,
                isSelected: item.isselected?true:false,
                qtype:item.qtype?item.qtype:item.qtype,
                isRight:JSON.parse(this.currentQA.rightAnswer).includes(item.letter)?true:false
              })
            },item=>(new Date().toString()+Math.random().toString()))
          }
        }
        .width('100%')
        .margin({ top: 10 })

        // 答案
        Column({ space: 30 }) {
          Column() {
            Text('答案')
              .fontWeight(600)
              .fontSize(18)
              .width('100%')
              .margin({ bottom: 20 })
            Row() {
              Text() {
                Span('正确答案: ')
                Span(JSON.parse(this.currentQA.rightAnswer).join())
                  .fontColor('#00cc9f')
              }
              .layoutWeight(1)

              Text() {
                Span('你的答案: ')
                Span(this.userAnswerChars.join().toString())
                  .fontColor('#f83b43')
              }
              .layoutWeight(1)
            }
          }

          Column() {
            Text('解析')
              .fontWeight(600)
              .fontSize(18)
              .width('100%')
              .margin({ bottom: 20 })
            Row() {
              Text() {
                Span(this.currentQA.solution)
                  .fontColor('#00cc9f')
              }
              .layoutWeight(1)

            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 30 })

      }
      .padding({ left: 15, right: 15 })
      .layoutWeight(1)
      // 切换上一题 下一题
      Row() {
        Row() {
          Image($r('app.media.ic_left'))
            .width(18)
            .aspectRatio(1)
            .margin({ right: 15 })
          Text('上一题')
        }
        .layoutWeight(1)
        .enabled(this.currentIndex !== 0)
        .opacity(this.currentIndex !== 0 ? 1 : .5)
        .onClick(() => {
          this.currentIndex--;
          if (this.currentIndex <= 0) {
            this.currentIndex = 0;
          }
          this.initCurrentQA();
        })

        Row() {
          Text('下一题')
            .margin({ right: 15 })
          Image($r('app.media.ic_right'))
            .width(18)
            .aspectRatio(1)
        }
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
        .enabled(this.currentIndex !== this.totalCout - 1)
        .opacity(this.currentIndex !== this.totalCout - 1 ? 1 : .5)
        .onClick(() => {
          this.currentIndex++;
          if (this.currentIndex >= this.totalCout) {
            this.currentIndex = this.totalCout - 1;
          }
          this.initCurrentQA();
        })
      }
      .height(50)
      .width('100%')
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f9f9f9')
  }
}