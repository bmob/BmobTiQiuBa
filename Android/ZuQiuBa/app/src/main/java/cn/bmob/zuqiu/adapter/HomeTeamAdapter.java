package cn.bmob.zuqiu.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiuj.bean.Team;

public class HomeTeamAdapter extends BaseAdapter{

	private Context mContext;
	private List<Team> teams = new ArrayList<Team>();
	private int selectedItem;
	
	public HomeTeamAdapter(Context mContext, List<Team> teams) {
		super();
		this.mContext = mContext;
		this.teams = teams;
	}

	public void setTeams(List<Team> teams) {
		this.teams = teams;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return teams.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return teams.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		ViewHolder viewHolder = null;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.list_single_choice, null);
			viewHolder.teamName = (TextView)convertView.findViewById(R.id.item_title);
			viewHolder.checkBox = (CheckBox)convertView.findViewById(R.id.item_check);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		Team team = teams.get(position);
		viewHolder.teamName.setText(team.getName());
		if(selectedItem == position){
			viewHolder.checkBox.setChecked(true);
		}else{
			viewHolder.checkBox.setChecked(false);
		}
		return convertView;
	}
	
	
	public void setSelectedItem(int positioin){
		selectedItem = positioin;
	}

	private class ViewHolder{
		TextView teamName;
		CheckBox checkBox;
	}
}
