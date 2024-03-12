import { Constants } from '../../common/Constants'
import router from '@ohos.router';
import { AgUser } from '../../services/Auth';
import DatabaseHelper from '../../services/DatabaseHelper';
import { chapqalog } from '../../models/chapqalog';
import { chapqa } from '../../models/chapqa';
import { formatDate } from '../../common/utils';
import ProcessLine from '../../components/ProcessLine';

class ParamsType {
  cid: number
}

@Entry
@Component
struct QuizResult {
  list: string[] = Array.from({ length: 20 }, (_, index) => index + 1 + '');
  private cid = 0; // 当前考卷id
  @State score: number = 0; //得分
  @State title: string = ""; //试卷标题
  @State submitDate: string = ""; //交卷时间

  @State totalCout: number = 0; //总题数
  @State rightCout: number = 0; //答对题数
  @State failCout: number = 0; //错误题数
  @State totalMins: string = "0"; //总用时分钟

  @State _userSelectedAwser: chapqalog[] = [new chapqalog()]; //用户答题集合，遍历生成答题卡正确/错误

  @StorageLink('user') currentUser: AgUser = new AgUser();
  @State processShow: boolean = true;

  async aboutToAppear() {
    try {
      let params: ParamsType = router.getParams() as ParamsType;
      this.cid = params.cid;

      // 1. 获取试卷信息
      const chaplist = await DatabaseHelper.ChapList_Query_By_cid(this.cid); //获取试卷信息
      // 2. 获取答卷信息
      //获取当前用户做的试卷结果
      const chaploglist = await DatabaseHelper.ChapLog_Query(this.cid, this.currentUser.uid.toString());
      // 3. 获取答卷明细
      this._userSelectedAwser = await DatabaseHelper.ChapQALog_Query_User_Select_Answer1(this.cid, this.currentUser.uid.toString());

      // 赋值操作
      this.score = chaploglist[0].score; //得分
      this.title = chaplist[0].title; //练习类型
      this.submitDate = formatDate(chaploglist[0].endDate); //提交答卷时间

      this.totalCout = this._userSelectedAwser.length; //答题总数
      this.rightCout = this._userSelectedAwser.filter(item => item.isRight).length; //正确的题数
      this.failCout = this.totalCout - this.rightCout; //错误的题数
      this.totalMins = ((chaploglist[0].endDate - chaploglist[0].startDate) / 1000 / 60).toFixed(0); //答题分钟

      this.processShow = false;

    } catch (err) {
      this.processShow = false;

      console.log('QuizResult.ets aboutToAppear error', JSON.stringify(err));
    }
  }

  async reSet() {
    AlertDialog.show({
      title: '重新刷题',
      message: '数据将会被重置，确定吗？',
      secondaryButton: {
        value: '取消',
        action: () => {}
      },
      primaryButton: {
        value: '确定',
        action: async () => {
          // 1. 把表chaplog数据删除 条件： cid && uid
          let chaplogs = await DatabaseHelper.ChapLog_Query(this.cid, this.currentUser.uid.toString());
          // 2.把表chapqalog数据删除  cid && uid
          let chapqalogs = await DatabaseHelper.ChapQALog_Query_User_Select_Answer1(this.cid, this.currentUser.uid.toString());
          await DatabaseHelper.ChapLog_Delete(chaplogs);
          await DatabaseHelper.ChapQALog_Delete(chapqalogs);

          //   3. 跳转到刷题页面
          router.pushUrl({ url: Constants.PAGE_QUIZ, params: { id: this.cid } });
        }
      }
    })

  }

  build() {
    Scroll() {
    Stack(){
      Column() {
        // 标题
        Text('答题结果')
          .fontSize(18)
          .fontWeight(600)
          .padding(15)

        // 得分
        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Gauge({ value: this.score, min: 0, max: 100 })
              .startAngle(270)
              .endAngle(90)
              .colors([[Constants.BLUE_LIGHT_COLOR, this.score], [Constants.GRAY_FULL_COLOR, 100 - this.score]])
              .strokeWidth(20)
              .width(200)
            Column() {
              this.smallText('得分')
              Text(this.score.toString())
                .fontSize(35)
                .fontWeight(900)
              this.smallText('/100')
              Row() {
                this.smallText('练习类型:')
                Text(this.title)
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .width('100%')
              .padding({ top: 50, bottom: 10 })
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                this.smallText('交卷时间:')
                Text(this.submitDate)
                  .fontSize(12)
                  .fontColor(Color.Gray)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
          }

        }
        .padding(20)
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(10)


        // 考试情况
        Column() {
          Text('考试情况')
            .width('100%')
            .fontWeight(600)
            .padding({ top: 20, bottom: 10 })
          Row() {
            this.examItem({
              title: '总题数',
              num: `${this.totalCout}`,
              unit: '题',
              fontColor: Constants.BLUE_LIGHT_COLOR
            })
            this.examItem({
              title: '答对',
              num: `${this.rightCout}`,
              unit: '题',
              fontColor: Constants.RIGHT_FULL_COLOR
            })
            this.examItem({
              title: '答错',
              num: `${this.failCout}`,
              unit: '题',
              fontColor: Constants.ERROR_FULL_COLOR
            })
            this.examItem({
              title: '总用时',
              num: `${this.totalMins}`,
              unit: 'min',
              fontColor: Constants.NORMAL_COLOR
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor(Color.White)
          .padding(20)
          .borderRadius(10)
        }


        // 答题卡
        Column() {
          Text('答题卡')
            .width('100%')
            .fontWeight(600)
            .padding({ top: 30, bottom: 10 })
          Column() {


            Row({ space: 15 }) {
              Text('单项选择题')
                .layoutWeight(1)
                .fontSize(14)
              Row({ space: 8 }) {
                Text()
                  .size({ width: 12, height: 12 })
                  .borderRadius(8)
                  .backgroundColor(Constants.GRAY_FULL_COLOR)
                Text('未答')
                  .fontSize(12)
              }

              Row({ space: 8 }) {
                Text()
                  .size({ width: 12, height: 12 })
                  .borderRadius(8)
                  .backgroundColor(Constants.RIGHT_FULL_COLOR)
                Text('答对')
                  .fontSize(12)
              }

              Row({ space: 8 }) {
                Text()
                  .size({ width: 12, height: 12 })
                  .borderRadius(8)
                  .backgroundColor(Constants.ERROR_FULL_COLOR)
                Text('答错')
                  .fontSize(12)
              }
            }
            .width('100%')
            .padding(15)
            // 答题卡选项
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this._userSelectedAwser, (item: chapqalog, index: number) => {
                Row() {
                  if (item.isRight) {
                    this.cardItem({ txt: (index + 1).toString(), color: Constants.RIGHT_FULL_COLOR })
                  } else {
                    this.cardItem({ txt: (index + 1).toString(), color: Constants.ERROR_FULL_COLOR })
                  }
                }
                .justifyContent(FlexAlign.Center)
                .width('20%')
                .aspectRatio(1)
                .onClick(() => {
                  router.pushUrl({ url: Constants.PAGE_ANSWER, params: { id: item.cid, currentIndex: index } });
                })
              })
            }
          }
          .backgroundColor(Color.White)
          .borderRadius(10)
        }

        Button('重新刷题')
          .width(200)
          .height(45)
          .margin({ bottom: 30,top:30 })
          .onClick(() => {
            this.reSet();
          })
      }
      .padding({ left: 15, right: 15, bottom: 50 })
      .width('100%')
      .linearGradient({
        colors: [
          ['#ccdffc', 0],
          [Constants.GRAY_LIGHT_COLOR, 1]
        ]
      })

      if(this.processShow){
        ProcessLine()
      }

    }
    }
  }

  @Builder
  cardItem(params: {
    txt: string,
    color: string
  }) {
    Text(params.txt)
      .textAlign(TextAlign.Center)
      .fontColor(Color.White)
      .size({ width: 40, height: 40 })
      .borderRadius(20)
      .backgroundColor(params.color)
  }

  @Builder
  examItem(parms: {
    title: string,
    num: string,
    unit: string,
    fontColor: ResourceColor
  }) {
    Column({ space: 15 }) {
      Text(parms.title)
        .fontSize(13)
      Text() {
        Span(parms.num)
          .fontSize(16)
          .fontColor(parms.fontColor)
        Span(parms.unit)
          .fontColor(parms.fontColor)
          .fontSize(12)
      }
    }
  }

  @Builder
  smallText(text: string, fontSize: number = 12) {
    Text(text)
      .fontSize(fontSize)
      .fontColor(Color.Gray)
  }
}