package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.LeagueDetailAdapter;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.League;
/*
* 联赛详情
* */
public class LeagueDetailActivity extends BaseActivity implements OnPageChangeListener{

	private ViewPager viewpager;
	private LeagueDetailAdapter mAdapter;
	
	private League currentLeague;
	
	private ImageView reportShare;
    private LinearLayout circleLayout;
    private ImageView circleIndicator;
    private ImageView[] circleIndicators;

    private int page;


	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarTitle, "联赛积分榜", 0, View.VISIBLE);
		setViewContent(R.layout.activity_league_detail);
		currentLeague = (League) getIntent().getSerializableExtra("league");
        //跳转页面
        page = getIntent().getIntExtra("page",0);
        //设置当前联赛
		MyApplication.getInstance().setCurrentLeague(currentLeague);
		
		mAdapter = new LeagueDetailAdapter(getSupportFragmentManager(), currentLeague);
        int count = mAdapter.getCount();
        //设置小黄点
        circleIndicators = new ImageView[count];
        for(int i=0;i<count;i++){
            circleIndicator=new ImageView(this);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.leftMargin = 16;
            lp.rightMargin = 16;
            circleIndicator.setLayoutParams(lp);
            circleIndicators[i]=circleIndicator;
            if (i==0){
                circleIndicators[i].setBackgroundResource(R.drawable.bg_circle_indicator_chosen);
            }else {
                circleIndicators[i].setBackgroundResource(R.drawable.bg_circle_indicator_normal);
            }
            circleLayout.addView(circleIndicators[i]);
        }
		viewpager.setAdapter(mAdapter);
		viewpager.setOffscreenPageLimit(4);
		viewpager.setOnPageChangeListener(this);
        //设置当前页
        setCurrentPager(page);
	}

	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		viewpager = (ViewPager)contentView.findViewById(R.id.detail_viewpager);
        circleLayout = (LinearLayout)contentView.findViewById(R.id.viewGroup);
		reportShare = (ImageView)contentView.findViewById(R.id.report_share);
		reportShare.setOnClickListener(this);
	
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.report_share:
			if(currentLeague==null){
				return;
			}
			switch (viewpager.getCurrentItem()) {
			case 0:{
				ShareData data = new ShareData();
				data.setTitle("联赛积分榜");
				data.setText(currentLeague.getName()+"最新积分榜出炉了，欢迎查看。"+ShareHelper.getLeagueData(currentLeague.getObjectId()));
				data.setImageUrl(ShareHelper.iconUrl);
				data.setUrl(ShareHelper.getLeagueData(currentLeague.getObjectId()));
				ShareHelper.share(LeagueDetailActivity.this, data);
				break;
			}
			case 1:{
				ShareData data = new ShareData();
				data.setTitle("联赛射手榜");
				data.setText(currentLeague.getName()+"最新射手榜出炉了，一起来膜拜男神吧！"+
						ShareHelper.getLeagueData(currentLeague.getObjectId()));
				data.setImageUrl(ShareHelper.iconUrl);
				data.setUrl(ShareHelper.getLeagueShoter((currentLeague.getObjectId())));
				ShareHelper.share(LeagueDetailActivity.this, data);
				break;
			}
			default:
				break;
			}
			break;

		default:
			break;
		}
	}
	
	@Override
	public void onPageScrollStateChanged(int arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onPageScrolled(int arg0, float arg1, int arg2) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onPageSelected(int arg0) {
		// TODO Auto-generated method stub
        for(int i=0;i<circleIndicators.length;i++) {
            circleIndicators[arg0].setBackgroundResource(R.drawable.bg_circle_indicator_chosen);
            if (arg0!=i){
                circleIndicators[i].setBackgroundResource(R.drawable.bg_circle_indicator_normal);
            }
        }
		switch (arg0) {
		case 0:
			setUpAction(mActionBarTitle, "联赛积分榜", 0, View.VISIBLE);
			break;
		case 1:
			setUpAction(mActionBarTitle, "联赛射手榜", 0, View.VISIBLE);
			break;
		case 2:
			setUpAction(mActionBarTitle, "联赛结果", 0, View.VISIBLE);
			break;
		case 3:
			setUpAction(mActionBarTitle, "联赛赛程", 0, View.VISIBLE);
			break;
		default:
			break;
		}
	}

	public void setCurrentPager(int positon){
		viewpager.setCurrentItem(positon, false);
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
}
