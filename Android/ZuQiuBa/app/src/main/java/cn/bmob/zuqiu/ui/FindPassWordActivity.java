package cn.bmob.zuqiu.ui;


import java.util.List;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.User;

public class FindPassWordActivity extends BaseActivity{

	private EditText accountInput;
	private Button  accountCommit;
	
	private String phoneNumber;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_find_password);
		setUpAction(mActionBarTitle, getString(R.string.find_pwd_title), 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
	}

	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch(v.getId()) {
            case R.id.findback_commit:
            	  phoneNumber = accountInput.getText().toString().trim();
            	  if(TextUtils.isEmpty(phoneNumber)){
            		  showToast(getString(R.string.account_null_tips));
            		  return;
            	  }
            	  if(phoneNumber.length()!=11){
            		  showToast(getString(R.string.phone_format_error));
            		  return;
            	  }
            	  isRegistered(phoneNumber);
                break;

            default:
                break;
        }
	}
	
	private void isRegistered(String phone){
		BmobQuery<User> userQuery = new BmobQuery<User>();
		userQuery.addWhereEqualTo("username", phone);
		initProgressDialog(R.string.loding_tips);
		userQuery.findObjects(mContext, new FindListener<User>() {
			
			@Override
			public void onSuccess(List<User> arg0) {
				// TODO Auto-generated method stub
				dismissDialog();
				if(arg0.size()!=0){
					Intent intent = new Intent();
                    intent.setClass(mContext, IdentifyingActivity.class);
                    intent.putExtra("identify_type", "find_password");
                    intent.putExtra("phone", phoneNumber);
                    intent.putExtra("user", arg0.get(0));
                    startActivity(intent);
                    finish();
				}else{
                    showToast(getString(R.string.user_not_registered));
                }
			}
			
			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
				if(arg0==9010){
					showToast(getString(R.string.no_network));
				}
			}
		});
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
		accountInput = (EditText)contentView.findViewById(R.id.findback_input_content);
		accountCommit = (Button)contentView.findViewById(R.id.findback_commit);
		
		accountCommit.setOnClickListener(this);
	}

}
