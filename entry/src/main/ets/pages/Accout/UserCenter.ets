@Extend(Column) function setColumnStyle(height) {
  .height(height)
  .width('90%')
  .margin({ left: 16, right: 16 })
  .backgroundColor(Color.White)
  .borderRadius(8)
}

@Extend(Text) function setTextStyle() {
  .fontSize(10)
  .fontColor('#979797')
  .margin({ top: 10 })
}

@Extend(Text) function setTextStyle1() {
  .fontSize(14)
  .fontWeight(400)
  .padding(16)
}

import { BindEmailDialog } from '../../components/Accout/BindEmailDialog';
import Prompt from '@system.prompt';
import router from '@ohos.router';
import { Constants } from '../../common/Constants';
import { AGCAuth, AgUser } from '../../services/Auth';
import { formatDate } from '../../common/utils';
import UploadForGac from '../../common/uploadForGac';
import DatabaseHelper from '../../services/DatabaseHelper';
import { userHeadImg } from '../../models/userHeadImg';


@Entry
@Component
export struct UserCenter {
  @StorageLink('user') currentUser: AgUser = new AgUser();
  @State currentSize:number = 0  // 当前上传大小
  @State totalSize:number = 0 //上传文件总大小
  // agcAuth: AGCAuth = new AGCAuth(getContext(this)) // 初始化登录相关的操作对象

  async loginOut() {
    try {
      let islogout = await AGCAuth.logout();
      if (islogout) {
        router.replaceUrl({ url: Constants.PAGE_LOGIN });
      } else {
        Prompt.showToast({ message: '登出失败' })
      }
    }catch (err){
      console.log('logout error',JSON.stringify(err));
    }
  }

  // 文件上传进度回调函数
  /*eventData格式:
  {
    data:{
       uploadSize:10,
       totalSize:100
    }
  }
   * */
  uploadProgress(eventData){
    console.log('eventData->',JSON.stringify(eventData))
    this.currentSize = eventData.data.uploadSize;
    this.totalSize = eventData.data.totalSize;
  }

  // 选择头像上传
  async editImg() {
    // 注册emit
    UploadForGac.emitOn((eventData)=>{ this.uploadProgress(eventData); })

    // 用户上传
    let selectMaxNum = 1;
    let cloudStrageImgPaths = await UploadForGac.UploadImage(selectMaxNum);
    console.log("cloudStrageImgPaths:", cloudStrageImgPaths.length);
    if(cloudStrageImgPaths.length<=0){
      return Prompt.showToast({message:'上传头像失败'});
    }

  // 赋值
    let currentImgPath = cloudStrageImgPaths[0];
    this.currentUser.photoUrl = currentImgPath;

  // 保存图片地址到db中
    const obj = new userHeadImg();
    obj.setUid(this.currentUser.uid);
    obj.setImgurl(currentImgPath);
    let num = await DatabaseHelper.userHeadImg_Upsert([obj]);

    Prompt.showToast({message:'上传头像完成'});
  }

  // 定义自定义弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    builder: BindEmailDialog(),
    customStyle: true,
    autoCancel: true
  })

  build() {

    Row() {
      Column({ space: 20 }) {

        Progress({ value: this.currentSize, total: this.totalSize, type: ProgressType.Linear })
          .color('#0094ff')
          .width('100%')

        // 用户昵称和头像部分
        Stack() {
          Column() {
            // 头像+昵称
            Column() {
              Image(this.currentUser.photoUrl.toString())
                .width(64)
                .aspectRatio(1)
                .borderRadius(32)
                .interpolation(ImageInterpolation.High) //减轻低清晰度图片在放大显示时出现的锯齿问题
                .onClick(async ()=>{
                  try {
                    // 此处编写代码
                    await this.editImg();
                  } catch (err) {
                    console.log('mylog->',JSON.stringify(err))
                    throw err
                  }

                })

              Text('用户昵称')
                .fontSize(16)
                .fontWeight(400)
                .fontColor('#2B364B')
                .margin({ top: 12 })
            }
            .position({ x: 16, y: -32 })

            Row({ space: 35 }) {
              //   已刷题
              Column() {
                Text('已刷题数(道)')
                  .setTextStyle()
                Text('40')
                  .fontWeight(400)
                  .padding({ top: 5 })
              }
              //   错题数
              Column() {
                Text('错题数量(道)')
                  .setTextStyle()
                Text('40')
                  .fontWeight(400)
                  .padding({ top: 5 })
              }
              .padding({ right: 20 })
            }
            .height(80)
            .position({ x: '100%', y: 0 })
            .translate({ x: '-100%' })
          }
          .setColumnStyle(80)
        }
        .margin({ top: 88 })

        // 手机号码，上次登录时间部分
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Text('登录账号')
              .setTextStyle1()
            Text(this.currentUser.phone.length > 0 ? this.currentUser.phone.toString() : this.currentUser.email.toString())
              .setTextStyle1()
          }
          .height(44)

          Divider()
            .color('rgba(0,0,0,0.05)')
            .width('90%')

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Text('上次登录时间')
              .setTextStyle1()
            Text(formatDate(this.currentUser.lastLogin.toString()))
              .setTextStyle1()
          }
          .height(44)
        }
        .setColumnStyle(88)


        // 登出
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Text('登出')
              .setTextStyle1()
            Row() {
              Image($r('app.media.ic_right'))
                .width(16)
                .aspectRatio(1)
                .fillColor(Color.Gray)
            }
            .layoutWeight(1)
            .height(44)
            .justifyContent(FlexAlign.End)
          }
          .height(44)
        }
        .setColumnStyle(44)
        .onClick(() => {
          this.loginOut()
        })
      }
      .width('100%')
      .height('100%')

    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#E9F2FF', 0.01], ['#fff', 100]]
    })
  }
}