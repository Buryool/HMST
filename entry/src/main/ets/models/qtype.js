/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2020-2020. All rights reserved.
 * Generated by the CloudDB ObjectType compiler. DO NOT EDIT!
 */

class qtype {
    constructor() {
        this.qid = undefined;
        this.title = undefined;
        this.totalNum = undefined;
        this.imageUrl = undefined;
        this.isDel = false;
        this.remark = undefined;
    }

    setQid(qid) {
        this.qid = qid;
    }

    getQid() {
        return this.qid;
    }

    setTitle(title) {
        this.title = title;
    }

    getTitle() {
        return this.title;
    }

    setTotalNum(totalNum) {
        this.totalNum = totalNum;
    }

    getTotalNum() {
        return this.totalNum;
    }

    setImageUrl(imageUrl) {
        this.imageUrl = imageUrl;
    }

    getImageUrl() {
        return this.imageUrl;
    }

    setIsDel(isDel) {
        this.isDel = isDel;
    }

    getIsDel() {
        return this.isDel;
    }

    setRemark(remark) {
        this.remark = remark;
    }

    getRemark() {
        return this.remark;
    }
}

qtype.className = 'qtype';

export {qtype}