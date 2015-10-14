package cn.bmob.zuqiu.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.List;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiu.view.views.CircleImageView;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class MemberListAdapter extends BaseAdapter{

	private Context mContext;
	private List<User> data;
	private Team currentTeam;
	
	public MemberListAdapter(Context mContext, List<User> data,Team team) {
		super();
		this.mContext = mContext;
		this.data = data;
		this.currentTeam = team;
	}

	public void setData(List<User> data) {
		this.data = data;
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
	public View getView(final int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		final ViewHolder viewHolder;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.member_list_item, null);
			viewHolder.friendLogo = (CircleImageView)convertView.findViewById(R.id.friend_logo);
			viewHolder.friendName = (TextView)convertView.findViewById(R.id.friend_name);
			viewHolder.friendShip = (TextView)convertView.findViewById(R.id.friend_relation);
			viewHolder.deleteButton = (Button)convertView.findViewById(R.id.delete_button);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		if(BmobUser.getCurrentUser(mContext, User.class).getObjectId().equals(currentTeam.getCaptain().getObjectId())){
			viewHolder.deleteButton.setVisibility(View.VISIBLE);
		}else{
			viewHolder.deleteButton.setVisibility(View.GONE);
		}
		
		final User user = data.get(position);
        if(user.getAvator() != null && !TextUtils.isEmpty(user.getAvator().getFileUrl(mContext))){
            ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext), viewHolder.friendLogo, ImageLoadOptions.getOptions(R.drawable.detail_user_logo_default,-1));
        }else{
            viewHolder.friendLogo.setImageResource(R.drawable.detail_user_logo_default);
        }
        
		if(user.getNickname()!=null){
			viewHolder.friendName.setText(user.getNickname());
		}else{
			viewHolder.friendName.setText(user.getUsername());
		}
//		viewHolder.friendShip.setText("队友");
        viewHolder.friendShip.setText("");
		viewHolder.deleteButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				ToastUtil.showToast(mContext, "成功删除该队员。");
				TeamManager.deleteMember(mContext, currentTeam, user, new UpdateListener() {
					
					@Override
					public void onSuccess() {
						// TODO Auto-generated method stub
                        //创建踢出战队的消息
		    			PushMessage msg1 = PushMessageHelper.getKickTeamMessage(mContext,currentTeam);
                        //发送给目标用户
                        MyApplication.getInstance().getPushHelper2().push2User(user,msg1);
					}
					
					@Override
					public void onFailure(int arg0, String arg1) {
						// TODO Auto-generated method stub
						LogUtil.i("push","移除球员成功。"+arg0+arg1);
					}
				});
				data.remove(position);
				notifyDataSetChanged();
			}
		});
		return convertView;
	}
	
	private class ViewHolder{
        CircleImageView friendLogo;
		TextView friendName;
		TextView friendShip;
		Button deleteButton;
	}
	

}
