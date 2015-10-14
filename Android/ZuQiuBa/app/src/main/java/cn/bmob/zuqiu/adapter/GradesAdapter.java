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
import cn.bmob.zuqiuj.bean.Comment;
import cn.bmob.zuqiuj.bean.User;

public class GradesAdapter extends BaseAdapter{

	private Context mContext;
	private List<Comment> comments = new ArrayList<Comment>();
	
	public GradesAdapter(Context mContext, List<Comment> comments) {
		super();
		this.mContext = mContext;
		this.comments = comments;
	}

	public void setComments(List<Comment> comment){
		this.comments = comment;
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return comments.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return comments.get(position);
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
			convertView = LayoutInflater.from(mContext).inflate(R.layout.grades_item, null);
			viewHolder.gradesName = (TextView)convertView.findViewById(R.id.grades_name);
			viewHolder.gradesPoint = (TextView)convertView.findViewById(R.id.grades_points);
			viewHolder.gradesContent = (TextView)convertView.findViewById(R.id.grades_comment_content);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		Comment comment = comments.get(position);
//		User user = comment.getAccept_comm();
//		if(user.getNickname()==null){
//			viewHolder.gradesName.setText(comment.getAccept_comm().getUsername());
//		}else{
//			viewHolder.gradesName.setText(comment.getAccept_comm().getNickname());
//		}
        viewHolder.gradesName.setText(comment.getKomm().getNickname());
		viewHolder.gradesPoint.setText(comment.getScore()+"");
		viewHolder.gradesContent.setText(comment.getComment());
		return convertView;
	}

	class ViewHolder{
		TextView gradesName;
		TextView gradesPoint;
		TextView gradesContent;
	}
	
}
