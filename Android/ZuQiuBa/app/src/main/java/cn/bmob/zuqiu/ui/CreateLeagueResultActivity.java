package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;

public class CreateLeagueResultActivity extends BaseActivity{

	private String leagueName ;
//	private String tips = "联赛已成功创建，由于所需的输入数据较多，剩余步骤建议您用个人电脑访问XXX网址完成。" +
//			"你也可以通过手机浏览器来完成（不推荐）。";
    private String tips = "联赛已成功创建,踢球吧强烈建议您使用个人电脑访问tq.codenow.cn（网址）来管理联赛数据，以获得更好体验。您也可以继续在手机端完成操作，但输入部分数据时可能会造成不便。是否继续？";
	private TextView leagueTips;
	private Button continueButton;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_league_create_result);
		setUpAction(mActionBarTitle, "创建联赛", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		Bundle bd = getIntent().getBundleExtra("data");
		if(bd!=null){
			leagueName = bd.getString("name");
		}
		tips = leagueName+tips;
		leagueTips.setText(tips);
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		leagueTips = (TextView)contentView.findViewById(R.id.league_leading);
		continueButton = (Button)contentView.findViewById(R.id.league_continue);
		continueButton.setOnClickListener(this);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.league_continue:
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

}
