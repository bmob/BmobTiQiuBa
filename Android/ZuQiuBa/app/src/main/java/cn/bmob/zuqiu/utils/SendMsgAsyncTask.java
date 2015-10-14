package cn.bmob.zuqiu.utils;

import android.os.AsyncTask;
import android.os.Handler;

import com.nostra13.universalimageloader.utils.L;

import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.push.BaiduPush;
import cn.bmob.zuqiu.push.RestApi;

public class SendMsgAsyncTask {
    private BaiduPush mBaiduPush;
    private String mMessage;
    private Handler mHandler;
    private MyAsyncTask mTask;
    private String mUserId;
    private String mTag;
    private OnSendScuessListener mListener;
    private int mPushType = PUSHTYPE_TOUSER;
    private String mDeviceType = RestApi.DEVICE_TYPE_ANDROID;    // 设备类型默认3Android
    private String mChannelId;
    
    
    public static final int PUSHTYPE_TOUSER = 1;    // 发送给某人
    public static final int PUSHTYPE_TOTAG = 2;     // 发送给某渠道
    public static final int PUSHTYPE_TOALL = 3;     // 发送给所有人

    public interface OnSendScuessListener {
        void sendScuess();
    }

    public void setOnSendScuessListener(OnSendScuessListener listener) {
        this.mListener = listener;
    }

    Runnable reSend = new Runnable() {

        @Override
        public void run() {
            // TODO Auto-generated method stub
            L.i("resend msg...");
//			send();//重发
        }
    };

    public SendMsgAsyncTask(String jsonMsg, String useIdOrTag, String channelId, int pushType, String deviceType) {
        // TODO Auto-generated constructor stub
        mBaiduPush = MyApplication.getInstance().getPushHelper2().getBaiduPush();
        mMessage = jsonMsg;
        mPushType = pushType;
        mDeviceType = deviceType;
        mChannelId = channelId;
        if(mPushType == PUSHTYPE_TOUSER){
            mUserId = useIdOrTag;
        }else if(mPushType == PUSHTYPE_TOTAG){
            mTag = useIdOrTag;
        }
        mHandler = new Handler();
    }

    // 发送
    public void send() {
        if (NetUtil.isNetConnected(MyApplication.getInstance())) {//如果网络可用
            mTask = new MyAsyncTask();
            mTask.execute();
        } else {
            ToastUtil.showToast(MyApplication.getInstance(), "网络不可用");
        }
    }

    // 停止
    public void stop() {
        if (mTask != null)
            mTask.cancel(true);
    }

    class MyAsyncTask extends AsyncTask<Void, Void, String> {

        @Override
        protected String doInBackground(Void... message) {
            String result = "";
            
            switch (mPushType){
                case PUSHTYPE_TOUSER:
                    LogUtil.d("SendMsgAsyncTask", "ToUser:"+mUserId+" 发送内容："+mMessage);
                    result = mBaiduPush.PushMessage(mMessage, mUserId, mChannelId, mDeviceType);
                    break;
                case PUSHTYPE_TOTAG:
                    LogUtil.d("SendMsgAsyncTask", "ToTag:"+mTag+" 发送内容："+mMessage);
                    result = mBaiduPush.PushTagMessage(mMessage, mTag, mDeviceType);
                    break;
                case PUSHTYPE_TOALL:
                    LogUtil.d("SendMsgAsyncTask", "ToAll:"+mUserId+" 发送内容："+mMessage);
                    result = mBaiduPush.PushMessage(mMessage);
                    break;
            }
//            if(TextUtils.isEmpty(mUserId))
//                result = mBaiduPush.PushMessage(mMessage);
//            else
//                result = mBaiduPush.PushMessage(mMessage, mUserId);
            return result;
        }

        @Override
        protected void onPostExecute(String result) {
            // TODO Auto-generated method stub
            super.onPostExecute(result);
            L.i("send msg result:"+result);
            if (result.contains(BaiduPush.SEND_MSG_ERROR)) {// 如果消息发送失败，则100ms后重发
                mHandler.postDelayed(reSend, 100);
            } else {
                if (mListener != null)
                    mListener.sendScuess();
            }
        }
    }
}
