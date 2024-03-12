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

interface IAnswer {
  letter: string,
  txt: string,
  isselected: boolean
}

class Answer implements IAnswer {
  letter: string
  txt: string
  isselected: boolean

  constructor(answer: IAnswer) {
    this.letter = answer.letter;
    this.txt = answer.txt;
    this.isselected = answer.isselected;
  }
}

class ParamsType {
  id: number
}

@Entry
@Component
struct QuizIndex {
  @State qaList: chapqa[] = [new chapqa()]; // 题目列表
  @State answerList: Answer[] = [new Answer({ letter: 'A', txt: '', isselected: false })]; // 答案选项
  @State totalCout: number = 0; //总题量
  @State currentIndex: number = 0; //当前题目索引号
  @State currentQA: chapqa = new chapqa(); //当前题目
  private cid = 0; // 当前考卷id
  private userAnswerChars: string[] = []; //当前题目用户选择的答案标记：例如A,B等
  @StorageLink('user') currentUser: AgUser = new AgUser();
  private _userSelectedAwser: chapqalog[] = [];

  async aboutToAppear() {
    try {
      // 获取参数
      let params: ParamsType = router.getParams() as ParamsType;
      this.cid = params.id;

      // 获取数据
      let list = await DatabaseHelper.QuizList_Query(this.cid); //获取当前试卷所有的题目
      if (list && list.length > 0) {
        this.qaList = list;
        this.totalCout = list.length;

        // 获取用户在当前试卷中的所有的答题数据
        this._userSelectedAwser = await DatabaseHelper.ChapQALog_Query_User_Select_Answer1(this.cid, this.currentUser.uid.toString());

        // 初始化当前题目
        await this.initCurrentQA(); //初始化题目，如果用户已经做过的题目则回显答案
      }

    } catch (err) {
      console.log('QuizIndex.ets aboutToAppear error', JSON.stringify(err));
    }
  }


  async initCurrentQA() {
    this.currentQA = this.qaList[this.currentIndex];
    //答案选项文字数组
    let answerArr: string[] = JSON.parse(this.currentQA.answer) as string[];
    //答案选项数组
    let letterArr: string[] = JSON.parse(this.currentQA.letter) as string[];

    // 获取用户选择的当前题目答案begin
    let userAswers = []; // 用户针对当前题目做的答案
    let _qalog = new chapqalog();
    if (this._userSelectedAwser.length > 0) {
      _qalog = this._userSelectedAwser.find(item => item.cqaid === this.currentQA.cqaid);
      // console.log('_qalog',JSON.stringify(this._qalog));
      userAswers = _qalog ? JSON.parse(_qalog.userAnswer) : []; //["A","B"]
    }
    // 获取用户选择的当前题目答案end

    let awlist = [];
    answerArr.forEach((item: string, index: number) => {
      awlist.push(
        new Answer({ letter: letterArr[index], txt: item, isselected: userAswers.includes(letterArr[index])  })
      )
    })

    this.answerList = awlist;
  }

  // 改变答案选择状态
  async editItmeStatus(list: Answer[], index: number) {
    // 多选
    if (this.currentQA.qtype === '多选') {
      // 当前项取反
      list[index].isselected = !list[index].isselected;
    }
    else {
      // 先把全部答案重置为false
      list.forEach(item => {
        item.isselected = false;
      });
      // 当前点击item设置为true
      list[index].isselected = true;
    }
    // 将修改后的最新状态数据重新赋值回@State属性answerList，触发视图刷新后呈现选中状态
    this.answerList = list;

    return list;
  }

  // 获取用户选择当前题目的答案
  async getCurrentAswer(list: Answer[]): Promise<string[]> {
    let chars = [];
    //  获取用户选择的答案
    list.forEach(item => {
      if (item.isselected) {
        chars.push(item.letter);
      }
    });

    this.userAnswerChars = []; //先清空
    this.userAnswerChars = chars;

    return chars;
  }

  // 将当前题目答案保存到Chapqalog表中
  async asyncChapqalog(selectedAnwerChars: string[]) {
    // 准备对象
    let _qalog = new chapqalog();

    // 查询chapqalog表中是否有当前用户的答题数据
    // 如果有->修改数据
    let arr = await DatabaseHelper.ChapQALog_Query_User_Select_Answer(this.currentQA.cqaid, this.currentUser.uid.toString());
    if (arr.length > 0) {
      _qalog = arr[0];
    // 修改属性值
      _qalog.userAnswer = JSON.stringify(selectedAnwerChars);
      _qalog.isRight = selectedAnwerChars.sort().join() === JSON.parse(this.currentQA.rightAnswer).sort().join();
      _qalog.answerTime = new Date();
    }else{
      // 给对象属性赋值 -> 新增
      // _qalog.qalogid = //因为是主键自增，所以无需赋值，会自动在数据表中生成
      _qalog.cqaid = this.currentQA.cqaid;
      _qalog.cid = this.currentQA.cid;
      _qalog.qid = this.currentQA.qid;
      _qalog.userAnswer = JSON.stringify(selectedAnwerChars);
      _qalog.isRight = selectedAnwerChars.sort().join() === JSON.parse(this.currentQA.rightAnswer).sort().join();
      _qalog.answerTime = new Date();
      _qalog.uid = this.currentUser.uid;
    }

    // 更新内存中的答题数据
    let index = this._userSelectedAwser.findIndex(item => item.cqaid  === this.currentQA.cqaid
    && item.uid ===this.currentUser.uid.toString() );
    if (index > -1) {
      this._userSelectedAwser.splice(index, 1,_qalog);
    } else {
      this._userSelectedAwser.push(_qalog);
    }

    return await DatabaseHelper.ChapQALog_Upsert([_qalog]);
  }

  // 用户做题
  async selectAnswer(index) {
    let list: Answer[] = JSON.parse(JSON.stringify(this.answerList)) as Answer[];

    // 1. 实现用户选择答案后颜色改变
    await this.editItmeStatus(list, index);

    // 2.保存用户选择的答案
    let currentAswerChars = await this.getCurrentAswer(list);

    // 3.答案入库
    await this.asyncChapqalog(currentAswerChars);
  }

  async submitQA(){
    // 1. 获取当前用户当前考卷的所有答案
    let answers = await DatabaseHelper.ChapQALog_Query_User_Select_Answer1(this.cid, this.currentUser.uid.toString());
    let lng = this.qaList.length; //当前答卷所有题目数量
    // 答卷数量与试卷体量不相当，表示还有题目未完成，不能交卷
    console.log('submitQA->',answers.length,lng)
    if (answers.length !== lng) {
      AlertDialog.show({ message: '您还有题目未完成，暂不能交卷' });
      return;
    }


    // 2. 向表chaplog中插入一条数据
    // 按照答题日期正序排列 - 以便获取开始和最后答题时间
    answers.sort((pre, next) => {
      return pre.answerTime - next.answerTime;
    });
    // 获取开始答题时间和最后答题时间
    let startTime = answers[0].answerTime;
    let endTime = answers[answers.length-1].answerTime;

    // 实例化chaplog对象并赋值
    const chaplogObj = new chaplog();
    chaplogObj.setCid(this.cid); // 章节试卷id
    chaplogObj.setQid(this.currentQA.qid); // 章节所在分类id
    chaplogObj.setUid(this.currentUser.uid); // 用户id
    chaplogObj.setIsDone(true); // true表示已经完成答题
    let rightlength = answers.filter(item => item.isRight).length;  // 统计正确答案总数
    let score = (rightlength / lng * 100).toFixed(0);  // 计算分数
    chaplogObj.setScore(parseFloat(score));//设置分数
    chaplogObj.setStartDate(startTime); // 开始答题
    chaplogObj.setEndDate(endTime);  // 结束答题
    chaplogObj.setCurrentIndex(this.currentIndex); // 当前答题定格在的索引
    //设置用户名
    chaplogObj.setRemark(this.currentUser.phone.length>0?this.currentUser.phone:this.currentUser.email);


    // 3. 插入数据
    await DatabaseHelper.ChapLog_Upsert([chaplogObj]);

    router.pushUrl({ url: Constants.PAGE_QUIZ_RESULT, params: { cid: this.cid } });
  }

  // 自定义弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    // 构造器
    builder: AnswerSheetDialog({
      userSelectedAwser: this._userSelectedAwser,
      qaList: this.qaList,
      submitQA:()=>{this.submitQA()},
      setQA: (index) => {
        // AlertDialog.show({ message: 'cancel' })
        this.currentIndex = index;
        this.initCurrentQA();
      }
    }),
    // 对齐
    alignment: DialogAlignment.Bottom,
    customStyle: true

  })

  build() {
    Column() {
      Column() {

        // 顶部
        Stack({ alignContent: Alignment.End }) {
          Text('在线模拟')
            .width('100%')
            .fontSize(18)
            .fontWeight(600)
            .textAlign(TextAlign.Center)
          Image($r('app.media.ic_allread'))
            .width(20)
            .aspectRatio(1)
            .onClick(() => {
              this.dialogController.open();
            })
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
            ForEach(this.answerList, (item: IAnswer, index: number) => {
              OptionItem({ label: item.txt, isSelected: item.isselected })
                .onClick(async () => {
                  try {
                    let num = await this.selectAnswer(index);
                  } catch (err) {
                    console.log('做题操作错误', JSON.stringify(err));
                  }
                })
            })
          }
        }
        .width('100%')
        .margin({ top: 10 })

        Blank()

        if (this.currentIndex >= this.totalCout - 1) {
          // 交卷按钮
          Button('提交答案')
            .width(200)
            .height(45)
            .margin({ bottom: 60 })
            .onClick(async () => {
              try {
                await this.submitQA();
                this.dialogController.close();
              } catch (err) {
                Prompt.showToast({ message: JSON.stringify(err) });
              }
            })

        }
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