import router from '@ohos.router'
import { Constants } from '../../common/Constants'
import { chapqalog } from '../../models/chapqalog'
import { chapqa } from '../../models/chapqa';


@CustomDialog
export default struct AnswerSheetDialog {
  controller: CustomDialogController;
  setQA: (index) => void; // 回调页面方法，显示当前用户选择题目的信息
  submitQA:() => void; //提交答案
  userSelectedAwser: chapqalog[]; // 当前答卷每个题目用户选择的答案
  qaList: chapqa[]; // 当前答卷所有题目

  build() {
    Column() {
      // 标题
      Row() {
        Text('单项选择题')
        Blank()
        Image($r('app.media.ic_public_close_filled'))
          .width(20)
          .aspectRatio(1)
          .onClick(() => {
            this.controller.close()
          })
      }
      .width('100%')
      // 标识
      Row({ space: 40 }) {
        Row({ space: 8 }) {
          Text()
            .size({ width: 16, height: 16 })
            .borderRadius(8)
            .backgroundColor(Constants.GRAY_FULL_COLOR)
          Text('未答')
        }

        Row({ space: 8 }) {
          Text()
            .size({ width: 16, height: 16 })
            .borderRadius(8)
            .backgroundColor(Constants.RIGHT_FULL_COLOR)
          Text('已答')
        }

      }
      .width('100%')
      .padding({ top: 15, bottom: 15 })

      // 答题卡选项
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.qaList, (item: chapqa, index: number) => {
          Row() {
            if (this.userSelectedAwser.findIndex(log=>log.cqaid === item.cqaid) >-1) {
              Text((index + 1).toString())
                .textAlign(TextAlign.Center)
                .fontColor(Color.White)
                .size({ width: 40, height: 40 })
                .borderRadius(20)
                .backgroundColor(Constants.RIGHT_FULL_COLOR)
            } else {
              Text((index + 1).toString())
                .textAlign(TextAlign.Center)
                .fontColor(Color.White)
                .size({ width: 40, height: 40 })
                .borderRadius(20)
                .backgroundColor(Constants.GRAY_FULL_COLOR)
            }

          }
          .justifyContent(FlexAlign.Center)
          .width('20%')
          .aspectRatio(1)
          .onClick(()=>{
            this.setQA(index);
            this.controller.close();
          })
        })
      }
      .backgroundColor(Constants.GRAY_LIGHT_COLOR)

      // 交卷查看结果
      Button('提交答案')
        .margin(20)
        .width(200)
        .onClick(() => {
          this.controller.close();
          this.submitQA();
        })
    }
    .padding(20)
    .width('100%')
    .backgroundColor(Color.White)
  }
}