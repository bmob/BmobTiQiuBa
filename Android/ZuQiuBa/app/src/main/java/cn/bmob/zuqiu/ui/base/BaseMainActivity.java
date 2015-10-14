package cn.bmob.zuqiu.ui.base;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

import com.umeng.analytics.MobclickAgent;

import cn.bmob.v3.Bmob;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.ToastUtil;

public class BaseMainActivity extends FragmentActivity {
    protected String TAG;
    protected Context mContext;
    protected ProgressDialog progressDialog;

    @Override
    protected void onCreate(Bundle arg0) {
        // TODO Auto-generated method stub
        super.onCreate(arg0);
        TAG = this.getClass().getSimpleName();
        LogUtil.i("base", TAG);
        mContext = this;
        Bmob.initialize(this, Constant.BMOB_APP_ID);
    }

    public void showToast(String text) {
        ToastUtil.showToast(this, text);
    }

    public void redictTo(Context context, Class<? extends Activity> activity, Bundle bundle) {
        Intent intent = new Intent();
        intent.setClass(context, activity);
        if (bundle != null) {
            intent.putExtra("data", bundle);
        }
        startActivity(intent);
    }

    protected void initProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(mContext);
        }
        progressDialog.setMessage(getString(R.string.loding_tips));
        progressDialog.show();
    }

    protected void initProgressDialog(int loadingMsgId) {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(mContext);
        }
        progressDialog.setMessage(getString(loadingMsgId));
        progressDialog.show();
    }

    protected void dismissDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
