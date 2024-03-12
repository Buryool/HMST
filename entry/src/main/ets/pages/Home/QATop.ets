// 此组件作用：用来单独呈现答题排行榜
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';
import { AppStorageKit } from '../../common/AppStorageKit';
import { Constants } from '../../common/Constants';
import { Http2BufferClass } from '../../common/Http2Buffer';
import { PreferencesUtil } from '../../common/PreferencesUtil';
import { formatNickName, getPartalNickName } from '../../common/utils';
import ProcessLine from '../../components/ProcessLine';
import { chaplog } from '../../models/chaplog'
import { QATopModel } from '../../models/models';
import { userHeadImg } from '../../models/userHeadImg';
import DatabaseHelper from '../../services/DatabaseHelper';


@Extend(Text) function setTextStyle() {
  .fontSize(13)
  .fontWeight(400)
  .fontColor('#6F7579')
}

@Component
export struct QATTop {
  @State qatopList: QATopModel[] = [new QATopModel(new chaplog(), '', null)];
  @State isshowProcess: boolean = false;

  async aboutToAppear() {
    try {
      this.isshowProcess = true;
      await this.getData(1, 6);

      this.isshowProcess = false;
    } catch (err) {
      console.log('QATop.ets error', JSON.stringify(err))
      this.isshowProcess = false;
    }
  }

  // 获取刷题排行榜，默认为一页6条
  async getData(pageIndex: number, pageSize: number) {
    // 获取得分最高的6位选手，但是缺用户头像
    const list: chaplog[] = await DatabaseHelper.Home_Query_By_Page(pageIndex, pageSize);
    console.log('chaplog list:', JSON.stringify(list).slice(0, 800));
    // 设置头像
    const toplist = await this.CreateQATopModelList(list);
    console.log('toplist:', JSON.stringify(toplist).slice(0, 800));

    // 向首选项存数据
    let top3List = await this.setPreferencesData(toplist);

    // 获取卡片id，给卡片发送数据
    await this.sendDataToCard(toplist);


    // 处理用户名加密
    toplist.forEach(item => {
      item.accoutName = formatNickName(item.accoutName)
    });
    this.qatopList = toplist;
  }

  async sendDataToCard(toplist) {
    // 深拷贝一份数据后将headImg地址改掉
    const toplistClone = JSON.parse(JSON.stringify(toplist)) as QATopModel[];
    let top3qlist: QATopModel[] = [new QATopModel(new chaplog(), '', null)];
    toplistClone.forEach(item => {
      item.accoutName = getPartalNickName(item.accoutName);
      console.log('headImg:', item.headImg)
    })

    if (toplistClone.length >= 3) {
      top3qlist = toplistClone.slice(0, 3);
    } else {
      top3qlist = toplistClone.slice(0, toplistClone.length);
      if (top3qlist.length === 2) {
        top3qlist.push(toplistClone[1])
      } else {
        top3qlist.push(toplistClone[0]);
        top3qlist.push(toplistClone[0])
      }
    }

    let imgList = top3qlist.map(item=>item.headImg);
    Http2BufferClass.getList(imgList,getContext(this) , async (resList) => {
      let data = {
        name1: top3qlist[0].accoutName,
        score1: top3qlist[0].score,
        imgName1: resList[0].fileName,
        name2: top3qlist[1].accoutName,
        score2: top3qlist[1].score,
        imgName2: resList[1].fileName,
        name3: top3qlist[2].accoutName,
        score3: top3qlist[2].score,
        imgName3: resList[2].fileName,
        formImages: {
          [resList[0].fileName]: resList[0].formImages[resList[0].fileName],
          [resList[1].fileName]: resList[1].formImages[resList[1].fileName],
          [resList[2].fileName]: resList[2].formImages[resList[2].fileName]
        }
      }
      let formData = formBindingData.createFormBindingData(data);


      // 从首选项获取卡片id
      //  const cards:string[] = await AppStorageKit.GetCarkIds(getContext(this));
      const cards: string[] = await PreferencesUtil.getInstance().getFormIds(getContext(this));
      console.log('cards->', JSON.stringify(cards));

      cards.forEach(card=>{
        // 调用updateForm
        formProvider.updateForm(card, formData).then((data) => {
          console.info('QATop.ets updateForm success.' + JSON.stringify(data));
        }).catch((error) => {
          console.error('QATop.ets updateForm failed: ' + JSON.stringify(error));
        })
      })

    });
  }

  async setPreferencesData(toplist) {

    // 深拷贝一份数据后将headImg地址改掉
    const toplistClone = JSON.parse(JSON.stringify(toplist)) as QATopModel[];
    let lng = toplistClone.length;
    let index = 0;
    let top3qlist: QATopModel[] = [new QATopModel(new chaplog(), '', null)];

    console.log('toplistClone:', lng)

    toplistClone.forEach(item => {
      item.accoutName = getPartalNickName(item.accoutName);
      console.log('headImg:', item.headImg)
    })

    if (toplistClone.length >= 3) {
      top3qlist = toplistClone.slice(0, 3);
    } else {
      top3qlist = toplistClone.slice(0, toplistClone.length);
      if (top3qlist.length === 2) {
        top3qlist.push(toplistClone[1])
      } else {
        top3qlist.push(toplistClone[0]);
        top3qlist.push(toplistClone[0])
      }
    }
    // 向首选项
    AppStorageKit.SetRanking<QATopModel[]>(top3qlist, getContext(this));
    console.log('存首选项：', JSON.stringify(top3qlist))
    return top3qlist;

  }

  //根据刷题排行榜数据构造视图遍历的数据QATopModel数组，包含用户头像url
  async CreateQATopModelList(list: chaplog[]): Promise<QATopModel[]> {
    return new Promise(async (resolve, reject) => {
      // 获取到排名用户id
      const uids = list.map(item => item.uid);
      // 获取到所有用户头像数组
      const headImgs = await DatabaseHelper.userHeadImg_Query_By_uids(uids);

      //  遍历list，构造出QATopModel[]
      let QATopModelList: QATopModel[] = [];
      list.forEach(async (item: chaplog) => {
        let imgurl = await this.getImgUrl(item, headImgs); //用户头像
        const qaTopModel = new QATopModel(item, imgurl, null);
        QATopModelList.push(qaTopModel);
      });

      resolve(QATopModelList);
    })
  }

  // 获取当前头像url
  async getImgUrl(chaplog: chaplog, userHeadImgs: userHeadImg[]) {
    let userHead = userHeadImgs.find(u => u.uid === chaplog.uid);
    let randnum = Math.floor(Math.random() * Constants.USER_HEAD_IMGURLS.length);
    let imgurl = userHead ? userHead.imgurl : Constants.USER_HEAD_IMGURLS[randnum];
    return imgurl;
  }

  // 排名：1,2,3调用
  @Builder TopListItem(params: {
    index: number,
    nickname: string,
    score: number,
    headImgUrl: string
  }) {
    Stack({ alignContent: Alignment.Start }) {
      if (params.index === 0) {
        Image($r("app.media.ic_1"))
          .height(48)
      } else if (params.index == 1) {
        Image($r("app.media.ic_2"))
          .height(48)
      } else {
        Image($r("app.media.ic_3"))
          .height(48)
      }

      Row({ space: 8 }) {
        Image(params.headImgUrl)
          .height(40)
          .aspectRatio(1)
          .borderRadius(15)
        Text(params.nickname)
          .fontSize(13)
          .fontWeight(400)
        Blank()
        Text(params.score + '')
      }
      .padding({ left: 65 })
      .width('100%')
    }
    .clip(false)
  }

  @Builder TopListItemOther(params: {
    index: number,
    nickname: string,
    score: number,
    headImgUrl: string
  }) {
    Row() {
      Text(`${params.index + 1}`)
        .padding({ left: 16 })
      Row({ space: 8 }) {
        Image(params.headImgUrl)
          .height(30)
          .aspectRatio(1)
          .borderRadius(15)
          .margin({ right: 5 })
        Text(params.nickname)
          .fontSize(13)
          .fontWeight(400)
        Blank()
        Text(params.score + '')
      }
      .layoutWeight(1)
      .padding({ left: 45 })
    }
    .width('100%')

    .height(48)
  }

  build() {

    Stack() {
      Column() {
        Text('答题排行榜')
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontWeight(500)
          .padding({ top: 10, bottom: 12 })
        // 排行榜
        Column() {
          // 表头
          Row() {
            Text('排名')
              .setTextStyle()
              .width(60)
            Text('昵称')
              .setTextStyle()
              .layoutWeight(2)
            Text('答题成绩')
              .textAlign(TextAlign.End)
              .setTextStyle()
          }
          .padding({ bottom: 12, left: 9 })

          // 内容
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.qatopList, (item: QATopModel, index: number) => {
                if (index < 3) {
                  this.TopListItem({
                    index: index,
                    nickname: item.accoutName,
                    score: item.score,
                    headImgUrl: item.headImg
                  })
                } else {
                  this.TopListItemOther({
                    index: index,
                    nickname: item.accoutName,
                    score: item.score,
                    headImgUrl: item.headImg
                  })
                }

              }, item => Math.random()
                .toString())
            }
          }
          .width('100%')
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Vertical)
        }
        .clip(true)
        .width('100%')
        .height(395)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .padding({ top: 10, left: 7, right: 15, bottom: 50 })
        .shadow({ radius: 10, color: '#CAD4E8', offsetX: 10, offsetY: 10 })
      }
      .width('100%')
      .height('100%')
      .padding(16)

      if (this.isshowProcess) {
        ProcessLine();
      }
    }
    .width('100%')
    .height('100%')
  }
}