import cloud from '@hw-agconnect/cloud';
import schema from '../../resources/rawfile/schema.json';

const dbZone = 'hmqaZone';
import { qtype } from '../models/qtype';
import { chaplist } from '../models/chaplist';
import { chapqa } from '../models/chapqa';
import { chaplog } from '../models/chaplog';
import { chapqalog } from '../models/chapqalog';
import { Database, DatabaseZoneQuery } from '@hw-agconnect/cloud/src/main/ets/database/Database';
import { userHeadImg } from '../models/userHeadImg';

class DatabaseHelper {
  static database:Database = cloud.database({objectTypeInfo: schema,zoneName: dbZone});  //dbZone是在AGC中的存储区名称;

  //1. 获取考题大类数据
  static async QType_Query():Promise<qtype[]> {
    return await DatabaseHelper.database.collection(qtype).query().equalTo("isDel",false).get();
  }

  //TODO：根据编写其他数据库操作方法
  //2. 根据题库分类id获取其下面的所有章节数据，并且按照order进行升序排列
  static async ChapList_Query(qtypeid:number):Promise<chaplist[]> {
    return await DatabaseHelper.database.collection(chaplist).query().equalTo("qid",qtypeid).orderByAsc('order').get();
  }

  // 根据主键cid获取试卷数据
  static async ChapList_Query_By_cid(cid:number):Promise<chaplist[]> {
    return await DatabaseHelper.database.collection(chaplist).query().equalTo("cid",cid).get();
  }

  //3. 根据章节id获取其下的所有题目数据，按照order字段正序排列
  static async QuizList_Query(cid:number):Promise<chapqa[]> {
    return await DatabaseHelper.database.collection(chapqa).query().equalTo("cid",cid).orderByAsc('order').get();
  }

  //4. 新增或者更新章节题目做题答案
  static async ChapQALog_Upsert(objarr:chapqalog[]):Promise<number> {
    return await DatabaseHelper.database.collection(chapqalog).upsert(objarr);
  }

  //4.1 查询当前用户的做题答案
  // cqaid:考题id，uid：当前登录用户id -> 获取当前用户当前题目的答题数据
  static async ChapQALog_Query_User_Select_Answer(cqaid:number,uid:string):Promise<chapqalog[]>{
    return await DatabaseHelper.database.collection(chapqalog).query()
      .equalTo("cqaid",cqaid)
      .and()
      .equalTo('uid',uid)
      .get()
  }

  //4.2 cid:考卷id，uid：当前登录用户id  -->获取当前用户对应考卷的所有答题数据
  static async ChapQALog_Query_User_Select_Answer1(cid:number,uid:string):Promise<chapqalog[]>{
    return await DatabaseHelper.database.collection(chapqalog).query()
      .equalTo("cid",cid)
      .and()
      .equalTo('uid',uid)
      .orderByAsc('cqaid')
      .get()
  }

  // 5. 新增或者更新章节信息
  static async ChapLog_Upsert(objarr:chaplog[]):Promise<number> {
    return await DatabaseHelper.database.collection(chaplog).upsert(objarr);
  }

  // 6. 获取章节试卷信息
  static async ChapLog_Query(cid:number,uid:string):Promise<chaplog[]> {
    return await DatabaseHelper.database.collection(chaplog).query()
      .equalTo("cid",cid)
      .and()
      .equalTo("uid",uid)
      .get();
  }
  // 8.获取用户所做的试卷
  static async ChapLog_Query_By_Uid(uid:string):Promise<chaplog[]> {
    return await DatabaseHelper.database.collection(chaplog).query()
      .equalTo("uid",uid)
      .get();
  }

  // 7. 获取用户章节试卷做题信息
  static async ChapLog_Query_By_qiduid(qid:number,uid:string):Promise<chaplog[]> {
    return await DatabaseHelper.database.collection(chaplog).query()
      .equalTo("qid",qid)
      .and()
      .equalTo("uid",uid)
      .get();
  }


  //  删除
  static async ChapLog_Delete(list:chaplog[]){
    return await DatabaseHelper.database.collection(chaplog).delete(list);
  }

  static async ChapQALog_Delete(list:chapqalog[]){
    return await DatabaseHelper.database.collection(chapqalog).delete(list);
  }

  // 根据uid数组获取他们的头像
  static async userHeadImg_Query_By_uids(uids:string[]):Promise<userHeadImg[]> {
    return await DatabaseHelper.database.collection(userHeadImg).query().In('uid',uids).get();
  }

  // 新增或更新用户头像
  static async userHeadImg_Upsert(objarr:userHeadImg[]):Promise<number> {
    return await DatabaseHelper.database.collection(userHeadImg).upsert(objarr);
  }

  // 获取首页排行榜数据
  static async Home_Query_By_Page(pageIndex:number,pageSize:number = 6):Promise<chaplog[]> {
    let limitCout = (pageIndex - 1) * pageSize;
    return await DatabaseHelper.database.collection(chaplog).query().orderByDesc("score").limit(pageSize,limitCout).get();
  }

}

export default DatabaseHelper;