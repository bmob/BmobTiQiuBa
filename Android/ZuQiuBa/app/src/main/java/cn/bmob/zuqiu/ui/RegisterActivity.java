package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.User;

public class RegisterActivity extends BaseActivity{

	private EditText accountInput;
	private EditText passwordInput;
	private EditText inviteCodeInput;
	
	private Button registerCommit;
	
	private String phoneNumber;
	private String password;
	private String inviteCode;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_register);
		setUpAction(mActionBarTitle, getString(R.string.register), 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		
	}

	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		accountInput = (EditText)contentView.findViewById(R.id.register_input_content);
		passwordInput = (EditText)contentView.findViewById(R.id.pwd_input_content);
		inviteCodeInput = (EditText)contentView.findViewById(R.id.invite_input_content);
		
		registerCommit = (Button)contentView.findViewById(R.id.register_commit);
		registerCommit.setOnClickListener(this);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.register_commit:
			//检验手机是否已注册。是则提示。否则跳转到验证码界面
//			if(isReistered()){
//
//			}else{
//				redictTo(mContext, IdentifyingActivity.class, null);
//			}
			phoneNumber = accountInput.getText().toString().trim();
			password = passwordInput.getText().toString().trim();
			inviteCode = inviteCodeInput.getText().toString().trim();
			if(TextUtils.isEmpty(accountInput.getText().toString().trim())){
				if(accountInput.getText().toString().trim().length()!=11){
					showToast(getString(R.string.phone_format_error));
					return;
				}
				showToast(getString(R.string.account_null_tips));
				return;
			}
			if(TextUtils.isEmpty(passwordInput.getText().toString().trim())){
				showToast(getString(R.string.pwd_null_tips));
				return;
			}
            checkUser();

//			User user = new User();
//			user.setUsername(phoneNumber);
//			user.setPassword(password);
//			user.signUp(mContext, new SaveListener() {
//
//				@Override
//				public void onSuccess() {
//					// TODO Auto-generated method stub
//					showToast(getString(R.string.register_success));
//					Bundle bundle = new Bundle();
//					bundle.putString("phone_number", phoneNumber);
//					bundle.putString("password", password);
//					if(!TextUtils.isEmpty(inviteCode)){
//						bundle.putString("invite_code", inviteCode);
//					}
//					redictTo(mContext, IdentifyingActivity.class, bundle);
//				}
//
//				@Override
//				public void onFailure(int statusCode, String arg1) {
//					// TODO Auto-generated method stub
//					showToast(getString(R.string.register_failed));
//					LogUtil.i(TAG,"register failed:"+statusCode+arg1);
//					showToast("register failed:"+statusCode+arg1+TAG);
//					switch (statusCode) {
//					case 9010:
//						showToast(getString(R.string.no_network));
//						break;
//					case 202:
//						showToast(getString(R.string.user_already_registered));
//						break;
//					default:
//						break;
//					}
//				}
//			});
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

    private void checkUser(){
        BmobQuery<User> query = new BmobQuery<User>();
        query.addWhereEqualTo("username", phoneNumber);
        query.findObjects(this, new FindListener<User>() {
            @Override
            public void onSuccess(List<User> users) {
                if(users.size()>0){
                    showToast(getString(R.string.user_already_registered));
                }else{
                    Bundle bundle = new Bundle();
                    bundle.putString("phone_number", phoneNumber);
                    bundle.putString("password", password);
                    if(!TextUtils.isEmpty(inviteCode)){
                        bundle.putString("invite_code", inviteCode);
                    }
                    redictTo(mContext, IdentifyingActivity.class, bundle);
                    finish();
                }
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

}
