import { Home } from './Home/Home';
import { UserCenter } from './Accout/UserCenter';
import { QList } from './BrushQuest/QList';
import { AppStorageKit } from '../common/AppStorageKit';
import router from '@ohos.router';
import { Constants, PublishEventType } from '../common/Constants';
import { SubscriberClass } from '../common/SubscriberClass';
import { PreferencesUtil } from '../common/PreferencesUtil';

@Entry
@Component
struct Index {
  // Tab设置相关的变量
  private tabsController: TabsController = new TabsController()
  @State currentIndex: number = 0
  private  subscriber = null;

  async aboutToAppear() {

    // 订阅卡片发送过来的卡片id
    // 通知元服务存储卡片id
    SubscriberClass.subscribe(PublishEventType.CARD_PUBLISH,this.subscriber,(cardID)=>{
    // 卡片id
      // 将卡片id存储在首选项中
      PreferencesUtil.getInstance().addFormId(getContext(this), cardID);
    })

    let user = await AppStorageKit.GetLoginUser(getContext(this));
    console.log('loginUser->', JSON.stringify(user));
    if (user.uid) {
      await AppStorageKit.SetLoginUser(user, getContext(this));
    } else {
      router.replaceUrl({ url: Constants.PAGE_LOGIN });
    }
  }
  /*
  title：tab 标题
  * targetIndex：当前tab的索引，用来匹配用户点击了哪一个
  * selectedImg：选择后的图片
  * normalImg:正常显示的图片
   * */
  @Builder TabBuilder(title: string,
                      targetIndex: number,
                      normalImg: Resource,
                      selectedImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 30, height: 30 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);

    })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          if (this.currentIndex === 0) {
            Home()
          }
        }
        .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_home'), $r('app.media.ic_home_actived')))

        TabContent() {
          if (this.currentIndex === 1) {
            QList()
          }
        }
        .tabBar(this.TabBuilder('练习', 1, $r('app.media.ic_practice'), $r('app.media.ic_practice_actived')))

        TabContent() {
          if (this.currentIndex === 2) {
            UserCenter()
          }
        }
        .tabBar(this.TabBuilder('我的', 2, $r('app.media.ic_mine'), $r('app.media.ic_mine_actived')))
      }
      .scrollable(false) //不允许通过滑动切换页面
    }
  }
}