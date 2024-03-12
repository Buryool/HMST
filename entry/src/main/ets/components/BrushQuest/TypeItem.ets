import router from '@ohos.router'

@Component
export struct TypeItem {
  title:string = "";  // 标题
  @Prop current:number; //当前章数进度
  total:number =10;//总章数
  imgUrl:string = "";

  build() {
    Flex() {
      Image($r('app.media.ic_cover1'))
        .alignSelf(ItemAlign.Center)
        .height(80)
        .width(60)
        .borderRadius(10)

      Column() {
        Column() {
          Text(this.title)
            .fontSize(14)
            .fontWeight(500)
            .textAlign(TextAlign.Start)
        }
        .alignSelf(ItemAlign.Start)
        .margin({ left: 10, top: 8 })

        Row() {
          Text(this.current.toString())
            .fontColor('#3266EE')
            .fontSize(12)
            .fontWeight(400)
          Text(`/${this.total?.toString()}节 | 已学进度：0%`)
            .fontColor('#979797')
            .fontSize(12)
            .fontWeight(400)
        }
        .width(137)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 24, left: 10 })

        Divider()
          // .width(200)
          .alignSelf(ItemAlign.Start)
          .margin({ left: 10, top: 6 })
      }
    }
    .height(96)
    .backgroundColor(Color.White)
    .borderRadius(9)
    .padding(10)

  }
}