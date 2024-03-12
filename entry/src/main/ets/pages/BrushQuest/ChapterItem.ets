@Component
export default struct ChapterItem {
  title: string = '' // 标题
  Level: string = '' // 难易
  isDone: boolean = false // 是否做题
  score:number = 0 //得分

  build() {
    Column({ space: 20 }) {
      Text(this.title)
        .alignSelf(ItemAlign.Start)
      Row() {
        this.tagBuilder(this.Level)
        Blank()
        Row() {
          if (!this.isDone) {
            // 未做题
            Text('暂未做题')
              .fontSize(13)
              .fontColor('#979797')
          } else {
            // 已完成
            Text() {
              Span('已完成')
                .fontSize(13)
                .fontColor('#00a4fa')
              Span(` | 得分:${this.score.toString()}`)

            }
            .fontSize(13)
          }
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 20, left: 16, right: 16, bottom: 20 })
  }

  @Builder
  tagBuilder(Level) {
    Text(Level)
      .fontColor(Level !=='简单' ? '#ff9670' : '#00bf67')
      .backgroundColor(Level !=='简单' ? '#fff6ed' : '#f0f9ec')
      .fontSize(12)
      .padding({ top: 3, left: 8, right: 8, bottom: 3 })
  }
}