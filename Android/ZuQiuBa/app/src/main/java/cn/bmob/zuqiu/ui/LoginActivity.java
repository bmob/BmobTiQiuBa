package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushManager;

import cn.bmob.v3.listener.SaveListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushHelper2;
import cn.bmob.zuqiuj.bean.User;


public class LoginActivity extends BaseActivity{

	private EditText accountInput;
	private EditText passwordInput;
	
	private TextView forgetPassword;
	
	private Button loginButton;
	private Button registerButton;
	
	private String phoneNumber;
	private String password;
	
    @Override
    protected void onCreate(Bundle bundle) {
        // TODO Auto-generated method stub
        super.onCreate(bundle);
        setViewContent(R.layout.activity_login);
        setUpAction(mActionBarTitle, getString(R.string.login), 0, View.VISIBLE);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        super.onClick(v);
        switch (v.getId()) {
		case R.id.login_forget_pwd:
			redictTo(mContext, FindPassWordActivity.class, null);
			break;
		case R.id.login_button:
            //隐藏软键盘
            ((InputMethodManager)getSystemService(INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(this.getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
            phoneNumber = accountInput.getText().toString().trim();
			password = passwordInput.getText().toString().trim();
			if(TextUtils.isEmpty(phoneNumber)){
				showToast(getString(R.string.pwd_null_tips));
				return;
			}
			if(TextUtils.isEmpty(password)){
				showToast(getString(R.string.pwd_null_tips));
				return;
			}
			
			User user = new User();
			user.setUsername(phoneNumber);
			user.setPassword(password);
            initProgressDialog("正在登录...");
			user.login(mContext, new SaveListener() {
				
				@Override
				public void onSuccess() {
					// TODO Auto-generated method stub
                    dismissDialog();
                    // 百度推送
                    PushManager.startWork(getApplicationContext(), PushConstants.LOGIN_TYPE_API_KEY, PushHelper2.API_KEY);
					finish();
					showToast(getString(R.string.login_success));
					redictTo(mContext, MainActivity.class, null);
				}
				
				@Override
				public void onFailure(int arg0, String arg1) {
					// TODO Auto-generated method stub
                    dismissDialog();
					LogUtil.i(TAG, "login failed:"+arg0+arg1);
					switch (arg0) {
					case 9010:
						showToast(getString(R.string.no_network));
						break;
					case 101:
						showToast(getString(R.string.user_or_pwd_error));
						break;
					default:
						break;
					}
				}
			});
			
			break;
		case R.id.register_button:
			Intent intent = new Intent();
			intent.setClass(LoginActivity.this, RegisterActivity.class);
			startActivity(intent);
            finish();
			break;
		default:
			break;
		}
    }

    @Override
    protected void onLeftMenuClick() {
        // TODO Auto-generated method stub
        super.onLeftMenuClick();
        finish();
    }

	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		accountInput = (EditText)contentView.findViewById(R.id.login_input_content);
		passwordInput = (EditText)contentView.findViewById(R.id.pwd_input_content);
		forgetPassword = (TextView)contentView.findViewById(R.id.login_forget_pwd);
		loginButton = (Button)contentView.findViewById(R.id.login_button);
		registerButton = (Button)contentView.findViewById(R.id.register_button);
		
		forgetPassword.setOnClickListener(this);
		loginButton.setOnClickListener(this);
		registerButton.setOnClickListener(this);
	}

}
