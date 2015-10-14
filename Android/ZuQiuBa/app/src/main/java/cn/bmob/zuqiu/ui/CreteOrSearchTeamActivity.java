package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.view.View;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.User;

public class CreteOrSearchTeamActivity extends BaseActivity{

	
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarTitle, "创建或搜索球队", 0, View.VISIBLE);
		Bundle bd = getIntent().getBundleExtra("data");
		CreateOrSearchcTeamFragment f = new CreateOrSearchcTeamFragment();
		if(bd!=null){
			f.setArguments(bd);
		}
		// 添加显示第一个fragment
        getSupportFragmentManager()
        .beginTransaction()
        .add(R.id.content_base,f)
        .commit();
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		findViewById(R.id.actionbar_base).setVisibility(View.GONE);
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
}
