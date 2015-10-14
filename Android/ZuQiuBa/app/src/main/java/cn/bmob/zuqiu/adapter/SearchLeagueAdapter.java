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
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.Team;

public class SearchLeagueAdapter extends BaseAdapter{

	private Context mContext;
	private List<League> leagues = new ArrayList<League>();
	
	public SearchLeagueAdapter(Context mContext, List<League> leagues) {
		super();
		this.mContext = mContext;
		this.leagues = leagues;
	}

	public void setTeams(List<League> leagues) {
		this.leagues = leagues;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return leagues.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return leagues.get(position);
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
			convertView = LayoutInflater.from(mContext).inflate(R.layout.team_list_item, null);
			viewHolder.teamName = (TextView)convertView.findViewById(R.id.team_item_name);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		League team = leagues.get(position);
		viewHolder.teamName.setText(team.getName());
		return convertView;
	}

	private class ViewHolder{
		TextView teamName;
	}
}
