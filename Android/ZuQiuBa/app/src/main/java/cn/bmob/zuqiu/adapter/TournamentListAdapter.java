package cn.bmob.zuqiu.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.TournamentHelper;
import cn.bmob.zuqiuj.bean.Tournament;

public class TournamentListAdapter extends BaseAdapter{

	private Context mContext;
	private List<Tournament> data;
	private boolean isLeague;
	private List<Integer> yearData = new ArrayList<Integer>();
	
	public TournamentListAdapter(Context mContext, List<Tournament> data,boolean isLeague) {
		super();
		this.mContext = mContext;
		this.data = data;
		this.isLeague = isLeague;
		for(Tournament t:data){
			yearData.add(TimeUtils.getCurrentYearNumber(t.getStart_time()));
		}
	}

	public void setData(List<Tournament> data) {
		this.data = data;
		for(Tournament t:data){
			yearData.add(TimeUtils.getCurrentYearNumber(t.getStart_time()));
		}
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return data.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return data.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		final ViewHolder viewHolder;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_competition, null);
			viewHolder.nearDate = (TextView)convertView.findViewById(R.id.near_com_date);
			viewHolder.nearTime = (TextView)convertView.findViewById(R.id.near_com_time);
			viewHolder.nearPeople = (TextView)convertView.findViewById(R.id.near_com_people);
			viewHolder.tournamentName = (TextView)convertView.findViewById(R.id.near_com_name);
			viewHolder.tournamentTeams = (TextView)convertView.findViewById(R.id.near_com_teams);
			viewHolder.tournamentSite = (TextView)convertView.findViewById(R.id.near_com_site);
			viewHolder.yearTime = (TextView)convertView.findViewById(R.id.time_year);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}

		Tournament mTournament = data.get(position);
		
		int section = getSectionForPosition(position);
		if(position == getPositionForSection(section)){
			viewHolder.yearTime.setVisibility(View.VISIBLE);
			viewHolder.yearTime.setText(yearData.get(position)+"年");
		}else{
			viewHolder.yearTime.setVisibility(View.GONE);
		}
		
		
		if(mTournament.getEvent_date()!=null)
			viewHolder.nearDate.setText(TimeUtils.getCompetitionDate(mTournament.getEvent_date()));
		if(mTournament.getStart_time()!=null)
			viewHolder.nearTime.setText(TimeUtils.getCompetitionTime(mTournament.getStart_time()));
		
		if(isLeague){
			if(mTournament.getLeague()!=null){
				viewHolder.tournamentName.setText(mTournament.getLeague().getName());
				viewHolder.nearPeople.setText(TournamentHelper.getNature(mTournament.getNature()));
				viewHolder.nearPeople.setVisibility(View.VISIBLE);
			}else{
				viewHolder.tournamentName.setText(mTournament.getName());
				viewHolder.nearPeople.setText("");
				viewHolder.nearPeople.setVisibility(View.GONE);
			}
		}else{
			viewHolder.nearPeople.setText("");
			viewHolder.tournamentName.setText(mTournament.getName());
		}
		
		viewHolder.tournamentTeams.setText(mTournament.getHome_court().getName()+"-"+mTournament.getOpponent().getName());
		viewHolder.tournamentSite.setText(mTournament.getSite());
		return convertView;
	}
	
	private class ViewHolder{
		TextView nearDate;
		TextView nearTime;
		TextView nearPeople;
		TextView tournamentName;
		TextView tournamentTeams;
		TextView tournamentSite;
		TextView yearTime;
	}
	
	/**
	 * 根据ListView的当前位置获取分类的首字母的Char ascii值
	 */
	public int getSectionForPosition(int position) {
		return yearData.get(position);
	}
	
	/**
	 * 根据分类的首字母的Char ascii值获取其第一次出现该首字母的位置
	 */
	public int getPositionForSection(int section) {
		for (int i = 0; i < getCount(); i++) {
			int sortStr = yearData.get(i);
			int firstChar = sortStr;
			if (firstChar == section) {
				return i;
			}
		}
		
		return -1;
	}
	
}
