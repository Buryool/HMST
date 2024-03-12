import { AGConnectUser, SignInResult, } from '@hw-agconnect/auth-ohos';
import '@hw-agconnect/auth-ohos';
import {
  PhoneAuthProvider,
  VerifyCodeSettingBuilder,
  VerifyCodeAction,
  EmailAuthProvider
} from '@hw-agconnect/auth-ohos';
import agconnect from '@hw-agconnect/api-ohos'
import { Log } from '../common/Log';
import { AppStorageKit } from '../common/AppStorageKit';

const TAG = "[AGCAuth]";

export class AGCAuth {

  // 获取当前登录的用户信息
  public static async getCurrentUser(): Promise<AGConnectUser> {
    return await agconnect.auth().getCurrentUser();
  }

  // 获取手机验证码
  public static async requestPhoneVerifyCode(phone: string, ctrCode: string = '+86') {
    try {
      let verifyCodeSettings = new VerifyCodeSettingBuilder()
        .setAction(1001) // 1001表示注册登录，1002表示修改密码
        .setLang('zh_CN')
        .setSendInterval(300)
        .build();

      let ret = await agconnect.auth().requestPhoneVerifyCode(
        ctrCode,
        phone,
        verifyCodeSettings);

      return '验证码获取成功';
    } catch (err) {
      Log.error(TAG, '手机验证码获取失败:' + JSON.stringify(err))
      throw err
    }
  }

  // 获取邮箱验证码
  public static async requestEmailVerifyCode(email: string) {
    try {
      let verifyCodeSettings = new VerifyCodeSettingBuilder()
        .setAction(1001) // 1001表示注册登录，1002表示修改密码
        .setLang('zh_CN')
        .setSendInterval(300)
        .build();

      let ret = await agconnect.auth().requestEmailVerifyCode(
        email,
        verifyCodeSettings);

      return '验证码获取成功';
    } catch (err) {
      Log.error(TAG, '邮箱验证码获取失败:' + JSON.stringify(err))
      throw err
    }
  }

  // 获取用户头像
  static async getImg(uid) {
    return "https://agc-storage-drcn.platform.dbankcloud.cn/v0/hmqa-bbnx2/defaultAvatar%2Fic_public_avatar1.png?token=ec5c702d-9ed9-4caf-ac7f-4ca205c70e68";
    /*
      const headImgs = await DatabaseHelper.userHeadImg_Query_By_uid(uid);
      if(headImgs && headImgs.length>0){
        return headImgs[0].imgurl;
      }else{
        return 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/hmqa-bbnx2/user_dark.png?token=74d1ae76-2075-4ab2-b702-74ee968eb6ed';
      }
      */
  }

  public static async Change(user: AGConnectUser) {
    try {
      let imgurl = await AGCAuth.getImg(user.getUid());

      let userExtra = await user.getUserExtra();

      let loginRes = new AgUser(
        user.getUid(),
        imgurl,
        user.getPhone(),
        user.getEmail(),
        user.getDisplayName(),
        userExtra.getCreateTime(),
        userExtra.getLastSignInTime());

      return loginRes;
    } catch (err) {
      Log.error(TAG, JSON.stringify(err))
      throw err
    }
  }

  // 手机验证码登录
  public static async login(isPhonelogin: boolean, username: string, verifyCode: string, countryCode: string = '+86'): Promise<AgUser> {
    try {
      let credential = null;
      if (isPhonelogin) {
        credential = PhoneAuthProvider.credentialWithVerifyCode(countryCode, username, verifyCode);
      } else {
        credential = EmailAuthProvider.credentialWithVerifyCode(username, verifyCode);
      }

      let ret: SignInResult = await agconnect.auth().signIn(credential)
      let user = ret.getUser()
      // 用户头像
      let loginRes = await AGCAuth.Change(user)
      AppStorageKit.SetLoginUser<AgUser>(loginRes, getContext(this))
      return loginRes
    } catch (err) {
      Log.error(TAG, JSON.stringify(err))
      throw err
    }
  }

  public static async logout(): Promise<boolean> {
    try {
      await agconnect.auth().signOut()
      return true
    } catch (err) {
      Log.error(TAG, JSON.stringify(err))
      throw err
    }
  }

  public async deleteUser(): Promise<boolean> {
    try {
      await agconnect.auth().deleteUser()
      return true
    } catch (err) {
      Log.error(TAG, JSON.stringify(err))
      throw err
    }

  }
}

export class AgUser {
  uid: String;
  photoUrl: String;
  phone: String;
  email: String;
  displayName: String;
  registerDate: String;
  lastLogin: String;

  constructor(uid: String = "", photoUrl: String = "", phone: String = "", email: String = "", displayName: String = "", registerDate: String = "", lastLogin: String = "") {
    this.uid = uid;
    this.photoUrl = photoUrl;
    this.phone = phone;
    this.email = email
    this.displayName = displayName;
    this.registerDate = registerDate;
    this.lastLogin = lastLogin;
  }

  getUid(): String {
    return this.uid;
  }

  getPhone(): String {
    return this.phone;
  }

  getEmail(): String {
    return this.email;
  }

  getDisplayName(): String {
    return this.displayName;
  }

  getPhotoUrl(): String {
    return this.photoUrl;
  }

  getRegisterDate(): String {
    return this.registerDate;
  }

  getLastLogin(): String {
    return this.lastLogin;
  }
}

