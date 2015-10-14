package cn.bmob.zuqiu.ui.base;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;

import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.ToastUtil;

public class BaseFragment extends Fragment implements OnClickListener{

	protected String TAG;
	protected TextView actionbarTitle;
	protected TextView rightMenu;
    protected ProgressDialog progressDialog;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		TAG = this.getClass().getSimpleName();
	}
	
	public View findViewById(int viewId){
		return getView().findViewById(viewId);
	}
	
	protected void setUpTitle(String title){
		actionbarTitle = (TextView)findViewById(R.id.actionbar_title);
		actionbarTitle.setText(title);
	}
	
	protected void setUpRightMenu(String text,int drawableId){
		rightMenu = (TextView)findViewById(R.id.actionbar_right_menu);
		rightMenu.setText(text);
		rightMenu.setCompoundDrawablesWithIntrinsicBounds(drawableId, 0, 0, 0);
		rightMenu.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.actionbar_right_menu:
			onRightMenuClick();
			break;
		case R.id.actionbar_title:
			
			break;
		default:
			break;
		}
	}

	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		
	}

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
	public void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
	}
	
	public void showToast(String toast){
		ToastUtil.showToast(getActivity(), toast);
	}
	
	
    protected void initProgressDialog(String msg){
        if(progressDialog==null){
            progressDialog = new ProgressDialog(getActivity());
        }
        progressDialog.setMessage(msg);
        if (!progressDialog.isShowing()) {
            progressDialog.show();
        }
    }

    protected void initProgressDialog(int loadingMsgId) {
        initProgressDialog(getString(loadingMsgId));
    }

    protected void dismissDialog(){
        if(progressDialog!=null){
            progressDialog.dismiss();
        }
    }
	
}
