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

public class LineupAdapter extends BaseAdapter{

	private Context mContext;
	private List<User> users = new ArrayList<User>();
	
	
	public LineupAdapter(Context mContext, List<User> users) {
		super();
		this.mContext = mContext;
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
		ViewHolder viewHolder =null;
		if(convertView==null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_lineup, null);
			viewHolder.name = (TextView)convertView.findViewById(R.id.name);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		final User user = users.get(position);
		if(user!=null){
			if(user.getNickname()!=null){
				viewHolder.name.setText(user.getNickname());
			}else{
				viewHolder.name.setText(user.getUsername());
			}
		}
		
		return convertView;
	}

	private class ViewHolder{
		TextView name;
	}
	
}
