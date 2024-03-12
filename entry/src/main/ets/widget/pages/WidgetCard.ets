class RankInfo {
  name: string = 'nickname'
  score: number = 60
  imgName: string = ''
}

const CARD_FIRST_COLOR: string = '#FFA621';
const CARD_SECOND_COLOR: string = '#929DCA';
const CARD_THIRD_COLOR: string = '#EA8F50';


let storage = new LocalStorage()

// 顶级组件
@Entry(storage)
@Component
struct RankCardCard {
  // @Provide
  // showData:Record<string,RankInfo> = {}

  // @Watch('updateData')


  // updateData(){
  //   this.showData = JSON.parse(this.data)
  // }
  build() {
    Stack() {
      // 背景图
      Image($r('app.media.ic_public_card_bg_svg'))
      // 排行图
      Image($r('app.media.ic_public_card_svg'))
        .width('85%')
      Row() {
        // 第二名
        SilverRankItem()
        // // 第一
        GoldenRankItem()
        // // 第三名
        CopperRankItem()
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .height(160)
      .width('100%')
      .onClick(() => {
        postCardAction(this, {
          'action': 'router',
          'abilityName': 'EntryAbility', // 只能跳转到当前应用下的UIAbility
          'params': {
            'behavior': 'rank'
          }
        });
      })
    }
    .width('100%')
    .height('100%')
  }
}


// 第一名
@Component
struct GoldenRankItem {
  @LocalStorageProp('name1') name1:string = '第一名'
  @LocalStorageProp('score1') score1:number = 100
  @LocalStorageProp('imgName1') imgName1:string =''
  // @LocalStorageProp('first') first: RankInfo = {
  //   name: '第一名',
  //   score: 100,
  //   imgName: ''
  // }

  build() {
    Column() {
      Image('memory://'+this.imgName1)
        .width(40)
        .border({ width: 2, color: CARD_FIRST_COLOR })
        .borderRadius(20)
        .aspectRatio(1)
      Image($r('app.media.ic_public_card_golden'))
        .width(28)
      Text(this.name1)
        .fontSize(14)
        .fontWeight(500)
        .margin({ top: 8 })
      Text(this.score1 + '')
        .fontColor(CARD_FIRST_COLOR)
        .fontSize(12)
        .fontWeight(700)
    }
    .alignSelf(ItemAlign.Start)
  }
}

// 第二名
@Component
struct SilverRankItem {
  @LocalStorageProp('name2') name2:string = '第二名'
  @LocalStorageProp('score2') score2:number = 100
  @LocalStorageProp('imgName2') imgName2:string =''

  // @LocalStorageProp('second') second: RankInfo = {
  //   name: '第二名',
  //   score: 90,
  //   imgName: ''
  // }

  build() {
    Column() {
      Image('memory://'+this.imgName2)
        .width(40)
        .border({ width: 2, color: CARD_SECOND_COLOR })
        .borderRadius(20)
        .aspectRatio(1)
      Image($r('app.media.ic_public_card_silver'))
        .width(28)
      Text(this.name2)
        .fontSize(14)
        .fontWeight(500)
        .margin({ top: 8 })

      Text(this.score2 + '')
        .fontColor(CARD_SECOND_COLOR)
        .fontSize(12)
        .fontWeight(700)
    }
    .alignSelf(ItemAlign.Center)
  }
}

// 第三名
@Component
struct CopperRankItem {
  @LocalStorageProp('name3') name3:string = '第三名'
  @LocalStorageProp('score3') score3:number = 100
  @LocalStorageProp('imgName3') imgName3:string =''
  // @LocalStorageProp('third') third: RankInfo = {
  //   name: '第三名',
  //   score: 80,
  //   imgName: ''
  // }

  build() {
    Column() {
      Image('memory://'+this.imgName3)
        .width(40)
        .border({ width: 2, color: CARD_THIRD_COLOR })
        .borderRadius(20)
        .aspectRatio(1)
      Image($r('app.media.ic_public_card_copper'))
        .width(28)
      Text(this.name3)
        .fontSize(14)
        .fontWeight(500)
        .margin({ top: 8 })

      Text(this.score3 + '')
        .fontColor(CARD_THIRD_COLOR)
        .fontSize(12)
        .fontWeight(700)
    }
    .alignSelf(ItemAlign.Center)
  }
}
