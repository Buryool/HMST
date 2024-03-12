import { TypeItem } from '../../components/BrushQuest/TypeItem' //练习列表项组件
import router from '@ohos.router'
import DatabaseHelper from '../../services/DatabaseHelper';
import { qtype } from '../../models/qtype';

import ProcessLine from '../../components/ProcessLine';
import { chaplog } from '../../models/chaplog'
import { AgUser } from '../../services/Auth';

@Entry
@Component
export struct QList {
  @State qtype: qtype[] = [new qtype()]; // 所有题库分类
  @State chaplogs: chaplog[] = [new chaplog()]; // 已经做完的试卷
  @StorageLink('user') currentUser: AgUser = new AgUser();
  @State processShow: boolean = true;

  async aboutToAppear() {
    try{
      // 1. 调用数据库方法获取所有题库分类数据
      this.qtype = await DatabaseHelper.QType_Query();

      // 根据uid获取当前做的试卷数量
      this.chaplogs = await DatabaseHelper.ChapLog_Query_By_Uid(this.currentUser.uid.toString());

      this.processShow = false;

    }catch(err){
      console.log('qlist.ets aboutToAppear error', JSON.stringify(err));
    }
  }

  build() {
    Row() {
      Stack() {
        List() {
          if (this.qtype[0].qid) {
            ForEach(this.qtype, (item: qtype, index: number) => {
              ListItem() {
                TypeItem({ title: item.title,
                  // 坑点
                  current:(this.chaplogs.filter(log=>log.qid === item.qid).length>0) ? (this.chaplogs.filter(log=>log.qid === item.qid).length): 0,
                  total: item.totalNum,
                  imgUrl:item.imageUrl
                })
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/BrushQuest/ChapterList', params: { id: item.qid } })
                  })
                  .padding({ top: 11, left: 15, right: 15 })
              }
            })
          }
        }
        .height('100%')

        // stack堆叠布局
        if (this.processShow) {
          ProcessLine()
        }
      }
    }
    .height('100%')
    .backgroundColor('#F5F7F9')
  }
}