package cn.bmob.zuqiu.adapter;

import java.util.ArrayList;
import java.util.List;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.ImageUtils;
import cn.bmob.zuqiuj.bean.User;

public class FriendListAdapter extends BaseAdapter{

	private Context mContext;
	private List<User> data;
	private List<Boolean> isFriend = new ArrayList<Boolean>();
	private List<User> friends = new ArrayList<User>();
	
	public FriendListAdapter(Context mContext, List<User> data) {
		super();
		this.mContext = mContext;
		this.data = data;
		friends = MyApplication.getInstance().getTeamMember();
		for(int i=0;i<data.size();i++){
			isFriend.add(Boolean.FALSE);
		}
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
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		final ViewHolder viewHolder;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.friend_list_item, null);
			viewHolder.friendLogo = (ImageView)convertView.findViewById(R.id.friend_logo);
			viewHolder.friendName = (TextView)convertView.findViewById(R.id.friend_name);
			viewHolder.friendShip = (TextView)convertView.findViewById(R.id.friend_relation);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		User user = data.get(position);
		for(int i=0;i<friends.size();i++){
			if(friends.get(i).getObjectId().equals(user.getObjectId())){
				isFriend.set(position, Boolean.TRUE);
			}
		}
//		if(user.getAvator()!=null){
//			if(user.getAvator()!=null){
//	    		ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext),
//	    				viewHolder.friendLogo, ImageLoadOptions.getRoundedOptions(R.drawable.friend_default_logo, 180),new SimpleImageLoadingListener(){
//
//							@Override
//							public void onLoadingComplete(String imageUri,
//									View view, Bitmap loadedImage) {
//								// TODO Auto-generated method stub
//								super.onLoadingComplete(imageUri, view, loadedImage);
//								int[] size = ImageUtils.getImageSize(mContext, R.drawable.friend_default_logo);
//								RelativeLayout.LayoutParams rp = new RelativeLayout.LayoutParams(size[0], size[1]);
//								rp.setMargins(16, 16, 16, 16);
//								viewHolder.friendLogo.setLayoutParams(rp);
//							}
//	    			
//	    		});
//	    	}
//		}
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
		if(isFriend.get(position)){
			viewHolder.friendShip.setText("队友");
		}else{
//			viewHolder.friendShip.setText("好友");
		}
		return convertView;
	}
	
	private class ViewHolder{
		ImageView friendLogo;
		TextView friendName;
		TextView friendShip;
	}
	

}
