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
import cn.bmob.zuqiuj.bean.User;

public class TeamMemberAdapter extends BaseAdapter{

	private Context mContext;
	private List<User> users = new ArrayList<User>();
	
	public TeamMemberAdapter(Context mContext, List<User> teams) {
		super();
		this.mContext = mContext;
		this.users = teams;
	}

	public void setData(List<User> users) {
		this.users = users;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return users.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return users.get(position);
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
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_zhenrong, null);
			viewHolder.teamName = (TextView)convertView.findViewById(R.id.member_name);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		User user = users.get(position);
		if(user.getNickname()!=null){
			viewHolder.teamName.setText(user.getNickname());
		}else{
			viewHolder.teamName.setText(user.getNickname());
		}
		
		return convertView;
	}

	private class ViewHolder{
		TextView teamName;
	}
}
