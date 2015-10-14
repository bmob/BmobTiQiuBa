package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import com.umeng.analytics.AnalyticsConfig;
import com.umeng.analytics.MobclickAgent;

import cn.bmob.v3.Bmob;
import cn.bmob.v3.BmobUser;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiuj.bean.User;

public class SplashActivity2 extends Activity {
    User user;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash2);

        MobclickAgent.updateOnlineConfig(this);
        /** 设置是否对日志信息进行加密, 默认false(不加密). */
        AnalyticsConfig.enableEncrypt(true);

		Bmob.initialize(this, Constant.BMOB_APP_ID);

		user = BmobUser.getCurrentUser(SplashActivity2.this, User.class);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if(user!=null){
                    Intent intent = new Intent();
                    intent.setClass(SplashActivity2.this, MainActivity.class);
                    startActivity(intent);
                }else{
                    Intent intent = new Intent();
                    intent.setClass(SplashActivity2.this, LoginActivity.class);
                    startActivity(intent);
                }
                finish();
            }
        },1000);
	}

}
