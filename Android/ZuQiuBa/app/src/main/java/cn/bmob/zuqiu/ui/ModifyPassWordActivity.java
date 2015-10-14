package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.ResetPasswordListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.User;


public class ModifyPassWordActivity extends BaseActivity{

    private EditText pwdInput;
    private EditText pwdMoreInput;
    
    private Button modifyCommit;
    private User mUser;
    
    private String newPassword;
    private String okPassword;
    
    private String identifyCode;
    private String phone;
    
    @Override
    protected void onCreate(Bundle bundle) {
        // TODO Auto-generated method stub
        super.onCreate(bundle);
        setViewContent(R.layout.activity_modify_pwd);
        setUpAction(mActionBarTitle, getString(R.string.modify_pwd_title), 0, View.VISIBLE);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
        
        Bundle bd = getIntent().getBundleExtra("data");
//        mUser = (User) bd.getSerializable("user");
        identifyCode = bd.getString("identify_code");
        phone = bd.getString("phone");
    }
    
    @Override
    protected void findViews(View contentView) {
        // TODO Auto-generated method stub
        pwdInput = (EditText)contentView.findViewById(R.id.pwd_input_content);
        pwdMoreInput = (EditText)contentView.findViewById(R.id.pwd_input_content_more);
        
        modifyCommit = (Button)contentView.findViewById(R.id.modify_commit);
        modifyCommit.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        super.onClick(v);
        switch(v.getId()) {
            case R.id.modify_commit:
                newPassword = pwdInput.getText().toString().trim();
                okPassword = pwdMoreInput.getText().toString().trim();
                if(TextUtils.isEmpty(newPassword)){
                	showToast(getString(R.string.modify_pwd_not_null_tips));
                	return;
                }
                if(TextUtils.isEmpty(okPassword)){
                	showToast(getString(R.string.modify_ok_pwd_not_null_tips));
                	return;
                }
                if(!newPassword.equals(okPassword)){
                	showToast(getString(R.string.modify_pwd_not_same));
                	return;
                }
                initProgressDialog(R.string.modify_loding_tips);
                
                
                if(!TextUtils.isEmpty(identifyCode)&&!TextUtils.isEmpty(phone)){
                    //BmobUser.resetPassword();
                    Log.d("bmob","phone="+phone+"  identifyCode="+identifyCode+"  newPassword="+newPassword);
                    BmobUser.resetPassword(mContext, phone, identifyCode, newPassword, new ResetPasswordListener() {
						
						@Override
						public void onSuccess() {
							// TODO Auto-generated method stub
							dismissDialog();
							showToast(getString(R.string.modify_success));
							Intent intent = new Intent();
							intent.setClass(mContext, LoginActivity.class);
							intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
							startActivity(intent);
						}
						
						@Override
						public void onFailure(int arg0, String arg1) {
							// TODO Auto-generated method stub
							LogUtil.i("Modify",arg0+arg1);
//							showToast(arg0+arg1);
							dismissDialog();
							switch (arg0) {
							case 9010:
								showToast(getString(R.string.no_network));
								break;
                                case 207:
                                    // 验证码错误
                                    showToast(getString(R.string.identify_code_not_match));
                                    break;
	
							default:
								break;
							}
						}
					});
                }
                
                
//                User user = new User();
//                mUser.setPassword(okPassword);
//                mUser.update(mContext,new UpdateListener() {
//					
//					@Override
//					public void onSuccess() {
//						// TODO Auto-generated method stub
//						dismissDialog();
//						showToast(getString(R.string.modify_success));
//						Intent intent = new Intent();
//						intent.setClass(mContext, LoginActivity.class);
//						intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//						startActivity(intent);
//					}
//					
//					@Override
//					public void onFailure(int arg0, String arg1) {
//						// TODO Auto-generated method stub
//						LogUtil.i("Modify",arg0+arg1);
//						showToast(arg0+arg1);
//						dismissDialog();
//						switch (arg0) {
//						case 9010:
//							showToast(getString(R.string.no_network));
//							break;
//
//						default:
//							break;
//						}
//					}
//				});
                
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
    
    

}
