package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.text.format.Time;
import android.view.Gravity;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextSwitcher;
import android.widget.TextView;
import android.widget.ViewSwitcher.ViewFactory;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.ImageUtils;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.UserHelper;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

public class UserInfoActivity extends BaseActivity implements ViewFactory,Runnable{

	private ImageView userLogo;
	private TextView userName;
	
	private TextView userAge;
	private TextView userLocation;
	private TextView userGoodAt;
	private TextView userHeight;
	private TextView userWeight;
	private TextSwitcher userTeam;
	private TextView userCity;
	
	private List<Team> teams = new ArrayList<Team>();
	
	private Handler handler = new Handler();
	private User mUser ;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_user_info);
		setUpAction(mActionBarTitle, "个人详情", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		mUser = (User) getIntent().getSerializableExtra("user");
		initUserInfo(mUser);
		initTeamInfo();
	}
	
	private void initTeamInfo(){
		if(mUser==null){
			return;
		}
		TeamManager.getTeams(mContext, mUser, new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> arg0) {
				// TODO Auto-generated method stub
				if(arg0!=null&&arg0.size()>0){
					teams.addAll(arg0);
					if(teams.size()>=2){
						handler.post(UserInfoActivity.this);
					}else{
						userTeam.setText(teams.get(0).getName());
					}
				}else{
					userTeam.setText("暂无");
				}
				
			}
			
			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}
		});
	}
	
	private void initUserInfo(User user){
		if(user!=null){
			if(user.getAvator()!=null){
	    		ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext),
	    				userLogo, ImageLoadOptions.getRoundedOptions(R.drawable.detail_user_logo_default, 180),new SimpleImageLoadingListener(){

							@Override
							public void onLoadingComplete(String imageUri,
									View view, Bitmap loadedImage) {
								// TODO Auto-generated method stub
								super.onLoadingComplete(imageUri, view, loadedImage);
								int[] size = ImageUtils.getImageSize(mContext, R.drawable.detail_user_logo_default);
								LinearLayout.LayoutParams rp = new LinearLayout.LayoutParams(size[0], size[1]);
								rp.gravity = Gravity.CENTER_HORIZONTAL;
								rp.setMargins(16, 16, 16, 16);
								userLogo.setLayoutParams(rp);
							}
	    			
	    		});
			}
			
			userAge.setText(TimeUtils.getAgeByDate(user.getBirthday())+"");
			
			if(!TextUtils.isEmpty(user.getNickname())){
	    		userName.setText(user.getNickname());
	    	}else{
	    		userName.setText(user.getUsername());
	    	}
			
			userLocation.setText(UserHelper.getUserLocation(user.getMidfielder()));
			userGoodAt.setText(UserHelper.getGoodat(user.getBe_good()));
			userHeight.setText(user.getHeight()+"cm");
			userWeight.setText(user.getWeight()+"kg");
			
			userCity.setText(user.getCityname());
		}
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		userLogo = (ImageView)contentView.findViewById(R.id.user_logo);
		userName = (TextView)contentView.findViewById(R.id.user_name);
		
		userAge = (TextView)contentView.findViewById(R.id.user_age_content);
		userLocation = (TextView)contentView.findViewById(R.id.user_location_content);
		userGoodAt = (TextView)contentView.findViewById(R.id.user_goodat_content);
		userHeight = (TextView)contentView.findViewById(R.id.user_height_content);
		userWeight = (TextView)contentView.findViewById(R.id.user_weight_content);
		userTeam = (TextSwitcher)contentView.findViewById(R.id.user_team_content);
		userCity = (TextView)contentView.findViewById(R.id.user_city_content);
	
		userTeam.setFactory(this);
        Animation in = AnimationUtils.loadAnimation(this, R.anim.top_in);//android.R.anim.slide_in_left);   
        Animation out = AnimationUtils.loadAnimation(this, R.anim.bottom_out);//android.R.anim.slide_out_right);   
        userTeam.setInAnimation(in);   
        userTeam.setOutAnimation(out);  
	}
	

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();

	}

	@Override
	public View makeView() {
		// TODO Auto-generated method stub
		 TextView textView = new TextView(this);   
	     textView.setTextSize(16);   
	     textView.setTextColor(Color.parseColor("#272f38"));
	     return textView; 
	}
	
	int i= -1;
	@Override
	public void run() {
		// TODO Auto-generated method stub
		i++;
		if(i>1){
			i = 0;
		}
		if(teams.size()>=2&&teams.size()>i){
			userTeam.setText(teams.get(i).getName());
			handler.postDelayed(this, 2000L);
		}else{
			if(teams.size()==1){
				userTeam.setText(teams.get(0).getName());
			}
		}
		
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		handler.post(this);
	}
	
	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		handler.removeCallbacks(this);
	}
}
