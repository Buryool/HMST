import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';

import { PreferencesUtil } from '../common/PreferencesUtil';
import formProvider from '@ohos.app.form.formProvider';
import { AppStorageKit } from '../common/AppStorageKit';
import { Http2BufferClass } from '../common/Http2Buffer';
import { SubscriberClass } from '../common/SubscriberClass';
import { PublishEventType } from '../common/Constants';


export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want) {
    console.log('进入onAddForm');

    let formData = {}
    // 从首选项获取排名前三的数据
    AppStorageKit.GetRank(this.context).then(ret => {
      //  卡片id固定
      let formId = want.parameters["ohos.extra.param.key.form_identity"];

      // 将卡片id存储在首选项中
      PreferencesUtil.getInstance().addFormId(this.context, formId);
      // 通知元服务存储卡片id
      SubscriberClass.publish(PublishEventType.CARD_PUBLISH,formId);

      let imgList = ret.map(item => item.headImg);

      console.log('imgList==>', JSON.stringify(imgList))
      Http2BufferClass.getList(imgList, this.context, (resList) => {
        /*
        [{"fileName":"/data/storage/el2/base/temp/file1705221948928","formImages":{"/data/storage/el2/base/temp/file1705221948928":34}},{"fileName":"/data/storage/el2/base/temp/file1705221949808","formImages":{"/data/storage/el2/base/temp/file1705221949808":35}},{"fileName":"/data/storage/el2/base/temp/file1705221950240","formImages":{"/data/storage/el2/base/temp/file1705221950240":36}}]
         * */
        console.log('resObj==>', JSON.stringify(resList))
        let data = {
          name1: ret[0].accoutName,
          score1: ret[0].score,
          imgName1: resList[0].fileName,
          name2: ret[1].accoutName,
          score2: ret[1].score,
          imgName2: resList[1].fileName,
          name3: ret[2].accoutName,
          score3: ret[2].score,
          imgName3: resList[2].fileName,
          formImages: {
            [resList[0].fileName]: resList[0].formImages[resList[0].fileName],
            [resList[1].fileName]: resList[1].formImages[resList[1].fileName],
            [resList[2].fileName]: resList[2].formImages[resList[2].fileName]
          }
        }

        // 卡片id固定
        let formId = want.parameters["ohos.extra.param.key.form_identity"];
        let formData = formBindingData.createFormBindingData(data);

        // 调用updateForm
        formProvider.updateForm(formId, formData).then((data) => {
          console.info('QATop.ets updateForm success.' + JSON.stringify(data));
        }).catch((error) => {
          console.error('QATop.ets updateForm failed: ' + JSON.stringify(error));
        })

      })


    })

    // ✨✨✨这句虽然此时没有用，但是不能少
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId) {
    // Called to notify the form provider to update a specified form.
  }

  onChangeFormVisibility(newStatus) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId, message) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};