package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.view.View;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;

/**
 * 个人详情页
 * @author venus
 *
 */
public class PersonalDetailActivity extends BaseActivity{

	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarTitle, getString(R.string.personal_detail), 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setViewContent(R.layout.activity_personal_detail);
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
}
