package cn.bmob.zuqiu.adapter;

import java.util.List;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.ViewGroup;

public class TeamArgueAdapter extends PagerAdapter{


	private Context mContext;
	List<View> views ;
	
	public TeamArgueAdapter(Context mContext, List<View> views) {
		super();
		this.mContext = mContext;
		this.views = views;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return views.size();
	}

	@Override
	public boolean isViewFromObject(View arg0, Object arg1) {
		// TODO Auto-generated method stub
		return arg0==arg1;
	}
	
	@Override
	public void destroyItem(
			ViewGroup container,
			int position, Object object)
	{
		((ViewPager)container).removeView(views.get(position));			
	}
	
	@Override
	public Object instantiateItem(
			ViewGroup container, int position)
	{
		((ViewPager)container).addView(views.get(position));
		return views.get(position);
	}	
}
