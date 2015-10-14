package cn.bmob.zuqiu.ui.base;


import cn.bmob.v3.BmobPushManager;
import cn.bmob.v3.BmobUser;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiuj.bean.User;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public abstract class BaseNavigationDrawerActivity extends FragmentActivity implements OnClickListener{
	protected String TAG ;
    protected Context mContext;
	
	protected TextView mActionBarTitle;
    protected TextView mActionBarLeftMenu;
    protected TextView mActionBarRightMenu;
    
    protected ProgressDialog progressDialog;
	@Override
	protected void onCreate(Bundle arg0) {
		// TODO Auto-generated method stub
		super.onCreate(arg0);
		setContentView(R.layout.activity_navigation_drawer_empty);
		
		TAG = getClass().getSimpleName();
        LogUtil.i("base", TAG);
        mContext = this;
		findViews();
        setListenter();
	}
	
	private void findViews() {
        mActionBarTitle = (TextView)findViewById(R.id.actionbar_title);
        mActionBarLeftMenu = (TextView)findViewById(R.id.actionbar_left_menu);
        mActionBarRightMenu = (TextView)findViewById(R.id.actionbar_right_menu);
    }
	
	private void setListenter() {
        mActionBarTitle.setOnClickListener(this);
        mActionBarLeftMenu.setOnClickListener(this);
        mActionBarRightMenu.setOnClickListener(this);
    }
	
    /**
     * 设置布局内容
     * @param layoutId
     */
    protected void setViewContent(int layoutId){
        FrameLayout baseContent = (FrameLayout)findViewById(R.id.content_frame);
        View contentView = LayoutInflater.from(this).inflate(layoutId, null);
        baseContent.addView(contentView,new RelativeLayout
        		.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
        				RelativeLayout.LayoutParams.MATCH_PARENT));
        findViews(contentView);
    }
    
    protected abstract void findViews(View contentView);
	
	/**
     * 设置action上左右菜单与标题 
     * @param tv
     * @param text
     * @param drawableId
     * @param visibility
     */
    protected void setUpAction(TextView tv,String text,int drawableId,int visibility){
        if(!TextUtils.isEmpty(text)){
            tv.setText(text);
        }
        if(drawableId!=0){
            tv.setCompoundDrawablesWithIntrinsicBounds(drawableId, 0, 0, 0);
        }
        if(tv.getVisibility()!=visibility){
            tv.setVisibility(visibility);
        }
    }
    
    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        switch(v.getId()) {
            case R.id.actionbar_title:
                onTitleClick();
                break;
            case R.id.actionbar_left_menu:
                onLeftMenuClick();
                break;
            case R.id.actionbar_right_menu:
                onRightMenuClick();
                break;
            default:
                break;
        }
    }

    protected void onTitleClick() {
        // TODO Auto-generated method stub
        
    }

    protected void onLeftMenuClick() {
        // TODO Auto-generated method stub
        
    }

    protected void onRightMenuClick() {
        // TODO Auto-generated method stub
        
    }

    public void showToast(String text){
        ToastUtil.showToast(this, text);
    }
    
    public void redictTo(Context context,Class<? extends Activity> activity,Bundle bundle){
    	Intent intent = new Intent();
    	intent.setClass(context, activity);
    	if(bundle!=null){
    		intent.putExtra("data", bundle);
    	}
    	startActivity(intent);
    }
    
	protected void initProgressDialog(int loadingMsgId) {
		if(progressDialog==null){
			progressDialog = new ProgressDialog(mContext);
		}
		progressDialog.setMessage(getString(loadingMsgId));
		progressDialog.show();
	}

	protected void dismissDialog(){
		if(progressDialog!=null){
			progressDialog.dismiss();
		}
	}
	
	protected void hideSoftInput(EditText input){
		InputMethodManager imm = (InputMethodManager)this.getSystemService(Context.INPUT_METHOD_SERVICE);  

		imm.hideSoftInputFromWindow(input.getWindowToken(), 0);
	}
	
	/**
	 * 显示键盘
	 */
	protected void showSoftInput() {
	    InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
	    View view = getCurrentFocus() != null ? getCurrentFocus() : findViewById(android.R.id.content);
	    imm.showSoftInput(view, InputMethodManager.SHOW_IMPLICIT);
	  }
	/**
	 * 隐藏键盘
	 */
	  protected void hideSoftInput() {
	    InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
	    View view = getCurrentFocus() != null ? getCurrentFocus() : findViewById(android.R.id.content);
	    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
	  }
	
	protected BmobPushManager getPushManager(){
		BmobPushManager manager = new BmobPushManager(mContext);
		return manager;
	}
	
	protected User getUser(){
		User user = BmobUser.getCurrentUser(mContext, User.class);
		return user;
	}
}
