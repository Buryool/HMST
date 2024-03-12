
import { chaplog } from './chaplog';

export class QATopModel {
  headImg: string; // 头像url
  accoutName: string; // 账号名称
  score: number; // 得分
  formImages:Record<string, number>; //内存图片对象

  constructor(chaplog:chaplog, imgurl: string,formImages) {
    this.headImg = imgurl;
    this.accoutName = chaplog.remark;
    this.score = chaplog.score;
    this.formImages = formImages;
  }
}


