package cn.bmob.zuqiu.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.User;

public class PlayScoreAdapter extends BaseAdapter{

	private Context mContext;
	private List<PlayerScore> scores;
	
	public PlayScoreAdapter(Context mContext, List<PlayerScore> scores) {
		super();
		this.mContext = mContext;
		this.scores = scores;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return scores.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return scores.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		ViewHolder holder = null;
		if(convertView == null){
			holder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_score_order, null);
			holder.playerName = (TextView) convertView.findViewById(R.id.order_name);
			convertView.setTag(holder);
		}else{
			holder = (ViewHolder) convertView.getTag();
		}
		
		final User user = scores.get(position).getPlayer();
		if(user.getNickname()!=null){
			holder.playerName.setText(user.getNickname());
		}else{
			holder.playerName.setText(user.getUsername());
		}
		
		return convertView;
	}

	
	private static class ViewHolder{
		TextView playerName;
	}
}
