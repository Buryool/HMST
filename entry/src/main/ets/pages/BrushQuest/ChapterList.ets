import router from '@ohos.router'
import Prompt from '@system.prompt';
import { Constants } from '../../common/Constants';
import ChapterItem from './ChapterItem';
import DatabaseHelper from '../../services/DatabaseHelper';
import { chaplist } from '../../models/chaplist';
import ProcessLine from '../../components/ProcessLine';
import { chaplog } from '../../models/chaplog';
import { AgUser } from '../../services/Auth';

class ParamsType {
  id: number
}

class chapListExt {
  score:number;
  isDone:boolean;
  title:string;
  level:string;
  cid:number;


  constructor(chaplist:chaplist,score,isDone) {
    this.cid = chaplist.cid;
    this.title = chaplist.title;
    this.level = chaplist.level;
    this.score = score;
    this.isDone = isDone;
  }
}

@Entry
@Component
struct ChapterList {
  @State chaplist: chaplist[] = [new chaplist()];
  @State chaplogList:chaplog[] = [new chaplog()];
  @State chapListExt:chapListExt[] = [new chapListExt(new chaplist(),0,false)];
  @StorageLink('user') currentUser: AgUser = new AgUser();
  @State processShow: boolean = true;

 async aboutToAppear() {
    try {
      // 获取路由参数
      // 注意：要在QList.ets中通过 router.pushUrl({ url: 'pages/BrushQuest/ChapterList', params: { id: item.qid } }) 将id传过来，才能获取到具体值
      let params: ParamsType = router.getParams() as ParamsType;
      let typeid = params.id;

      //获取章节数据
      await this.getchapList(typeid);

      this.processShow = false;

    } catch (err) {
      this.processShow = false;
      console.log('ChaperList.ets aboutToAppear error', JSON.stringify(err));
    }
  }

  async getchapList(typeid){
    this.chaplist = await DatabaseHelper.ChapList_Query(typeid);
    this.chaplogList = await DatabaseHelper.ChapLog_Query_By_qiduid(typeid,this.currentUser.uid.toString());
    console.log('getchapList-->',JSON.stringify(this.chaplist),JSON.stringify(this.chaplogList));

    this.chapListExt.length = 0;
    this.chaplist.forEach(item=>{
      let chaplog = this.chaplogList.find(log=>log.cid === item.cid);
      console.log('chaplog-->',JSON.stringify(chaplog));
      let score = 0;
      let isDone = false;
      if(chaplog){
        score = chaplog.score;
        isDone = chaplog.isDone;
      }
      this.chapListExt.push(new chapListExt(item,score,isDone));

    })

    console.log('chapListExt-->',typeid,this.currentUser.uid.toString(),JSON.stringify(this.chapListExt));
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Text('章节列表')
          .fontSize(18)
          .width('100%')
          .textAlign(TextAlign.Center)
        Image($r('app.media.ic_allread'))
          .width(20)
          .aspectRatio(1)
      }
      .width('100%')
      .padding({ top: 20, bottom: 20, left: 15, right: 15 })
      Stack() {
        List() {

          if (this.chapListExt[0].cid > 0) {
            ForEach(this.chapListExt, (item: chapListExt) => {
              ListItem() {
                ChapterItem({
                  title: item.title,
                  Level: item.level,
                  isDone: item.isDone,
                  score: item.score
                })
                  .onClick(()=>{
                    if(item.isDone){
                      router.pushUrl({ url: Constants.PAGE_QUIZ_RESULT, params: { cid: item.cid } });
                    }else{
                      router.pushUrl({ url: Constants.PAGE_QUIZ, params: { id: item.cid } });
                    }
                  })
              }
            })
          }
        }
        .divider({ strokeWidth: 1, startMargin: 15, endMargin: 15, color: '#D9D9D9' })
        .layoutWeight(1)
        .width('100%')
        .height('100%')
        .borderRadius(30)
        .backgroundColor(Color.White)

        // 提示正在加载中
        if (this.processShow) {
          ProcessLine()
        }
      }
    }
    .height('100%')
    .backgroundColor('#e9f3fe')
  }
}