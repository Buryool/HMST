@Component
struct ProcessLine {
  build() {
    Row() {
      LoadingProgress()
        .color('#2C80FF')
        .width(100)
        .height(100)
    }
    .width("100%")
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}

export default ProcessLine;