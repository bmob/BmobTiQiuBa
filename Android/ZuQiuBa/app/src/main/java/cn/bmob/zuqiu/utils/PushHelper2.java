package cn.bmob.zuqiu.utils;

import android.content.Context;

import com.baidu.android.pushservice.PushManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobPushManager;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.push.BaiduPush;
import cn.bmob.zuqiu.push.RestApi;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.PushMsg;
import cn.bmob.zuqiuj.bean.User;

/**
 * Created by BaiKing Rio on 2015/1/16.
 */
public class PushHelper2 {

    public static final String API_KEY = "";
    private static final String SECRIT_KEY = "";
    
    private Context context;
    private BmobPushManager manager;
    private BaiduPush mBaiduPushServer;
    public PushHelper2(Context context) {
        super();
        this.context = context;
        initManager();
    }

    public synchronized BaiduPush getBaiduPush() {
        if (mBaiduPushServer == null)
            mBaiduPushServer = new BaiduPush(BaiduPush.HTTP_METHOD_POST,
                    SECRIT_KEY, API_KEY);
        return mBaiduPushServer;

    }

    private BmobPushManager initManager(){
        if(manager == null){
            manager = new BmobPushManager(context);
        }
        return manager;
    }

    /*
    * 给指定用户发送消息
    * */
    public void push2User(final User targetUser,final PushMessage msg){
        //保存到后台表中
        final PushMsg pm = new PushMsg(targetUser.getUsername(),msg.getAps().getAlert(),msg.createExtra());
        pm.save(context,new SaveListener() {
            @Override
            public void onSuccess() {
                //设置这条消息的objectId
                msg.setObjectId(pm.getObjectId());
                //发送消息
                new SendMsgAsyncTask(msg.toJson(), targetUser.getPushUserId(), targetUser.getPushChannelId(), SendMsgAsyncTask.PUSHTYPE_TOUSER, BaiduPush.getDeviceType(targetUser.getDeviceType())).send();
            }

            @Override
            public void onFailure(int i, String s) {
                ToastUtil.showToast(MyApplication.getInstance(), "请求发送失败");
            }
        });
    }

    /*
    * 推送给指定用户
    * */
    public void pushToUser(final String channelId, final String userId, final JSONObject msg, final String deviceType){
        final PushMsg pm = new PushMsg();
        //消息接收方的账户
        pm.setBelongUsername(msg.optString("belongUsername"));
        //设置标题
        final JSONObject aps = msg.optJSONObject("aps");
        pm.setContent(aps.optString("alert"));
        //设置未读
        pm.setIsRead(0);
        msg.remove("belongUsername");
        pm.setExtra(msg.toString());
        pm.save(this.context, new SaveListener() {
            @Override
            public void onSuccess() {
                try {
                    msg.remove("extra");
                    msg.put("objectId", pm.getObjectId());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                new SendMsgAsyncTask(msg.toString(), userId, channelId, SendMsgAsyncTask.PUSHTYPE_TOUSER, deviceType).send();
            }
            @Override
            public void onFailure(int i, String s) {
                LogUtil.e("PushHelper2", "存储消息到服务端失败:"+s);
            }
        });
    }

    /*
    * 推送给指定对的所有队员
    * */
    public void pushToChannel(String tag, String msg){
        new SendMsgAsyncTask(msg, tag, "", SendMsgAsyncTask.PUSHTYPE_TOTAG, RestApi.DEVICE_TYPE_ANDROID).send();  // Android设备
        new SendMsgAsyncTask(msg, tag, "", SendMsgAsyncTask.PUSHTYPE_TOTAG, RestApi.DEVICE_TYPE_IOS).send();  // ios设备
    }

    public void setTag(String tag){
        List<String> tags = new ArrayList<String>();
        tags.add(tag);
        PushManager.setTags(context, tags);
    }
    
    public void deleteTag(String tag){
        List<String> tags = new ArrayList<String>();
        tags.add(tag);
        PushManager.delTags(context, tags);
    }
    
    // --------------------具体业务逻辑的消息发送-----------------------

//    /**
//     * 邀请入队的消息，由队长发送给被邀请的人
//     * @param msg
//     * @param targetUser
//     */
//    public void sendInviteIntoTheTeamByCaptain(PushMessage msg, User targetUser){
//        push2User(targetUser,msg);
//    }
//
//    /**
//     * 发送邀请入队的消息，由球员发送给本队队长
//     * @param msg
//     * @param targetUser
//     */
//    public void sendInviteIntoTheTeamByPlayer(PushMessage msg, User targetUser){
//        push2User(targetUser,msg);
//    }

}
