package cn.bmob.zuqiu.adapter;

import java.util.List;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiuj.bean.LeaguePlayerStat;
import cn.bmob.zuqiuj.bean.PlayerScore;

public class SheShouAdapter extends BaseAdapter{

	private Context mContext;
	private List<PlayerScore> data;
	
	
	public SheShouAdapter(Context mContext, List<PlayerScore> data) {
		super();
		this.mContext = mContext;
		this.data = data;
	}
	
	public void setData(List<PlayerScore> data){
		this.data = data;
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
		ViewHolder viewHolder;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_sheshou, null);
			viewHolder.order = (TextView)convertView.findViewById(R.id.paiming);
			viewHolder.playerName = (TextView)convertView.findViewById(R.id.qiuyuan);
			viewHolder.teamName = (TextView)convertView.findViewById(R.id.qiudui);
			viewHolder.myGoals = (TextView)convertView.findViewById(R.id.jinqiu);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		if(position%2==0){
			convertView.setBackgroundResource(R.drawable.bg_list_item_hui);
		}else{
			convertView.setBackgroundResource(R.drawable.back);
		}
		
		final PlayerScore stat = data.get(position);
		viewHolder.order.setText(position+1+"");
		if(stat.getPlayer().getNickname()!=null){
			viewHolder.playerName.setText(stat.getPlayer().getNickname());
		}else{
			viewHolder.playerName.setText(stat.getPlayer().getUsername());
		}
		
		viewHolder.teamName.setText(stat.getTeam().getName());
		viewHolder.myGoals.setText(stat.getGoals()+"");
		
		return convertView;
	}

	private class ViewHolder{
		TextView order;
		TextView playerName;
		TextView teamName;
		TextView myGoals;
	}
	
}
