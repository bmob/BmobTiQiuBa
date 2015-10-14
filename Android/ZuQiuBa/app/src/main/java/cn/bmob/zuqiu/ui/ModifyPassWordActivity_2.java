package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.provider.ContactsContract.CommonDataKinds.Relation;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.ResetPasswordListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.User;


public class ModifyPassWordActivity_2 extends BaseActivity{

	private RelativeLayout oldLayout;
	
	private EditText oldpwdInput;
    private EditText pwdInput;
    private EditText pwdMoreInput;
    
    private Button modifyCommit;
    private User mUser;
    
    private String oldPassword;
    private String newPassword;
    private String okPassword;
    
    
    @Override
    protected void onCreate(Bundle bundle) {
        // TODO Auto-generated method stub
        super.onCreate(bundle);
        setViewContent(R.layout.activity_modify_pwd);
        setUpAction(mActionBarTitle, getString(R.string.modify_pwd_title), 0, View.VISIBLE);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
    
    
    }
    
    @Override
    protected void findViews(View contentView) {
        // TODO Auto-generated method stub
    	oldLayout = (RelativeLayout)contentView.findViewById(R.id.old_pwd_input);
        oldLayout.setVisibility(View.VISIBLE);
    	pwdInput = (EditText)contentView.findViewById(R.id.pwd_input_content);
        pwdMoreInput = (EditText)contentView.findViewById(R.id.pwd_input_content_more);
        oldpwdInput = (EditText)contentView.findViewById(R.id.old_pwd_content);
        
        modifyCommit = (Button)contentView.findViewById(R.id.modify_commit);
        modifyCommit.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        super.onClick(v);
        switch(v.getId()) {
            case R.id.modify_commit:
            	oldPassword = oldpwdInput.getText().toString().trim();
                newPassword = pwdInput.getText().toString().trim();
                okPassword = pwdMoreInput.getText().toString().trim();
                
                if(TextUtils.isEmpty(oldPassword)){
                	showToast(getString(R.string.modify_old_pwd_not_null_tips));
                	return;
                }
                
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
                
                final User user = BmobUser.getCurrentUser(mContext, User.class);
                user.setPassword(oldPassword);
                user.login(mContext, new SaveListener() {
                    @Override
                    public void onSuccess() {
                        user.setPassword(okPassword);
                        user.update(mContext, new UpdateListener() {

                            @Override
                            public void onSuccess() {
                                // TODO Auto-generated method stub
                                dismissDialog();
                                showToast(getString(R.string.modify_success));
                                Intent intent1 = new Intent();
                                intent1.setClass(mContext, ModifyInfomationActivity.class);
                                intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                startActivity(intent1);
                                finish();
                            }

                            @Override
                            public void onFailure(int arg0, String arg1) {
                                // TODO Auto-generated method stub
                                LogUtil.i("Modify",arg0+arg1);
                                showToast(arg0+arg1);
                                dismissDialog();
                                switch (arg0) {
                                    case 9010:
                                        showToast(getString(R.string.no_network));
                                        break;

                                    default:
                                        break;
                                }
                            }
                        });
                    }

                    @Override
                    public void onFailure(int i, String s) {
                        dismissDialog();
                        showToast("原始密码不正确");
                    }
                });
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
