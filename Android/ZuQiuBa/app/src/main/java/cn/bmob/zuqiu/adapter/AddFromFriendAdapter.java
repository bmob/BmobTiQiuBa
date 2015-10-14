package cn.bmob.zuqiu.adapter;

import java.util.ArrayList;
import java.util.List;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.ImageUtils;
import cn.bmob.zuqiuj.bean.User;

public class AddFromFriendAdapter extends BaseAdapter{

	private Context mContext;
	private List<User> data = new ArrayList<User>();
	private int selectedItem;
	
	public AddFromFriendAdapter(Context mContext, List<User> data) {
		super();
		this.mContext = mContext;
		this.data = data;
	}

	public void setData(List<User> data){
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
		final ViewHolder viewHolder ;
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = ((LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.item_checkbox_icon_and_name, null);
			viewHolder.checkBox = (CheckBox)convertView.findViewById(R.id.item_check);
			viewHolder.icon = (ImageView)convertView.findViewById(R.id.item_icon);
			viewHolder.title = (TextView)convertView.findViewById(R.id.item_title);
			
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		User user = data.get(position);
		
		if(user.getNickname()!=null){
			viewHolder.title.setText(user.getNickname());
		}else{
			viewHolder.title.setText(user.getUsername());
		}
		
		if(user.getAvator()!=null){
			ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext),
    				viewHolder.icon, ImageLoadOptions.getRoundedOptions(R.drawable.detail_user_logo_default, 180),new SimpleImageLoadingListener(){

						@Override
						public void onLoadingComplete(String imageUri,
								View view, Bitmap loadedImage) {
							// TODO Auto-generated method stub
							super.onLoadingComplete(imageUri, view, loadedImage);
							int[] size = ImageUtils.getImageSize(mContext, R.drawable.detail_user_logo_default);
							RelativeLayout.LayoutParams rp = new RelativeLayout.LayoutParams(size[0], size[1]);
							rp.addRule(RelativeLayout.RIGHT_OF, viewHolder.checkBox.getId());
							rp.setMargins(16, 16, 16, 16);
							viewHolder.icon.setLayoutParams(rp);
						}
    			
    		});
		}
		
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
		ImageView icon;
		TextView title;
		CheckBox checkBox;
	}
	
}
