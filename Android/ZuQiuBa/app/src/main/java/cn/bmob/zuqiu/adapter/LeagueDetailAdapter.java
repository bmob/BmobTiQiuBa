package cn.bmob.zuqiu.adapter;

import cn.bmob.zuqiu.ui.JiFenFragment;
import cn.bmob.zuqiu.ui.LeagueResultFragment;
import cn.bmob.zuqiu.ui.LeagueSaichengFragment;
import cn.bmob.zuqiu.ui.SheShouFragment;
import cn.bmob.zuqiuj.bean.League;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;

public class LeagueDetailAdapter extends SmartFragmentStatePagerAdapter{

	private static int FRAGMENT_NUM = 4;
    private League league;
	
	public LeagueDetailAdapter(FragmentManager fragmentManager,League l) {
		super(fragmentManager);
        league = l;
		// TODO Auto-generated constructor stub
	}

	@Override
	public Fragment getItem(int position) {
		// TODO Auto-generated method stub
		if(this.getRegisteredFragment(position)!=null){
			return getRegisteredFragment(position);
		}else{
			switch (position) {
			case 0:
				return JiFenFragment.getInstance(position, league);
			case 1:
				return SheShouFragment.getInstance(position, league);
			case 2:
				return LeagueResultFragment.getInstance(position);
			case 3:
				return LeagueSaichengFragment.getInstance(position);
			}
			//0,积分榜
			//1,射手榜
			//2，联赛结果页
			//3,联赛赛程页
			return JiFenFragment.getInstance(position, league);
		}
		
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return FRAGMENT_NUM;
	}

}
