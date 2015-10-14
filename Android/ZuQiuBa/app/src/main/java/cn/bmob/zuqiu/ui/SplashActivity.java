package cn.bmob.zuqiu.ui;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushManager;

import cn.bmob.v3.Bmob;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.OtherLoginListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.User;

public class SplashActivity extends Activity implements OnClickListener{

    private Button login;
    private Button qqLogin;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);
		Bmob.initialize(this, Constant.BMOB_APP_ID);

		login = (Button)findViewById(R.id.login_or_register_splash);
		qqLogin = (Button)findViewById(R.id.qq_login_splash);
		
		login.setOnClickListener(this);
		qqLogin.setOnClickListener(this);
		User user = BmobUser.getCurrentUser(SplashActivity.this, User.class);
		if(user!=null){
			Intent intent = new Intent();
			intent.setClass(SplashActivity.this, MainActivity.class);
			startActivity(intent);
			finish();
		}
	}

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        switch(v.getId()) {
            case R.id.login_or_register_splash:
                //前往登录/注册界面
                Intent intent = new Intent();
                intent.setClass(SplashActivity.this, LoginActivity.class);
                startActivity(intent);
                break;
            case R.id.qq_login_splash:
                //调用openqq进行登录
            	BmobUser.qqLogin(this, "1102303926", new OtherLoginListener() {
            	    @Override
            	    public void onSuccess(JSONObject userAuth) {
            	        // TODO Auto-generated method stub
//            	        Toast.makeText(SplashActivity.this, "第三方登陆成功:"+userAuth.toString(), Toast.LENGTH_SHORT).show();
            	        BmobUser user = BmobUser.getCurrentUser(getApplicationContext());
            	        if(user==null){
            	        	LogUtil.i("LoginActivity","user is null");
            	        }else{
            	        	LogUtil.i("LoginActivity","user info:"+userAuth);
            	        	LogUtil.i("LoginActivity","user is not null"+user.getUsername());
            	        }
						Intent intent = new Intent();
						intent.setClass(SplashActivity.this, MainActivity.class);
						startActivity(intent);
						finish();
            	    }

            	    @Override
            	    public void onFailure(int code, String msg) {
            	        // TODO Auto-generated method stub
            	    	Toast.makeText(SplashActivity.this, "第三方登陆失败:"+msg, Toast.LENGTH_SHORT).show();
            	    }

                    @Override
                    public void onCancel() {
                        
                    }
                });
                break;
            default:
                break;
        }
    }

}
