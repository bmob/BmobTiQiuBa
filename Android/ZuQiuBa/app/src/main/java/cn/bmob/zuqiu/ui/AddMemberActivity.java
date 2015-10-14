package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.share.ZuQiuShare;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.Team;

public class AddMemberActivity extends BaseActivity{

	private EditText searchInput;
	private ImageButton searchFriend;
	
	private RelativeLayout addFriend;
	private RelativeLayout addPhone;
	private RelativeLayout addWechat;
	private RelativeLayout addQq;
	
	private String searchContent;
	private Team currentTeam;
	private ZuQiuShare share;
    
    private String downloadUrl = "http://tq.codenow.cn/share/Download";
    private String shareText = "";
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_add_member);
		setUpAction(mActionBarTitle, "添加队友", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		currentTeam = (Team) getIntent().getSerializableExtra("team");
		share = new ZuQiuShare(mContext);
        String name = getUser().getNickname()==null?getUser().getUsername():getUser().getNickname();
        shareText = name+"邀请您下载踢球吧，加入"+currentTeam.getName()+"队。请在注册时填写球队注册码"+currentTeam.getReg_code()+"。踢球吧，记录你的比赛！";
	}
		
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		searchInput = (EditText)contentView.findViewById(R.id.search_input);
		searchFriend = (ImageButton)contentView.findViewById(R.id.search_friend);
		addFriend = (RelativeLayout)contentView.findViewById(R.id.add_friend);
		addPhone = (RelativeLayout)contentView.findViewById(R.id.add_phone);
		addWechat = (RelativeLayout)contentView.findViewById(R.id.add_wechat);
		addQq = (RelativeLayout)contentView.findViewById(R.id.add_qq);
		
		addFriend.setOnClickListener(this);
		addPhone.setOnClickListener(this);
		addWechat.setOnClickListener(this);
		addQq.setOnClickListener(this);
		
		searchFriend.setOnClickListener(this);
	}

	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.search_friend:
			searchContent = searchInput.getText().toString().trim();
			if(TextUtils.isEmpty(searchContent)){
				showToast("请输入搜索内容。");
				return;
			}
			Intent intent = new Intent();
			intent.setClass(mContext, SearchMemberActivity.class);
			intent.putExtra("search_content", searchContent);
			startActivity(intent);
			hideSoftInput(searchInput);
			break;
		case R.id.add_phone:{
			ShareData data = new ShareData();
//			data.setText("Hi~！我正在使用“踢球吧”，看球，约球，踢球，场场都精彩，你也一起来吧！"+"http://www.bmob.cn/");
            data.setText(shareText+downloadUrl);
			share.shareToMsg(data);
		}
			break;
		case R.id.add_wechat:{
			ShareData data = new ShareData();
			data.setTitle("踢球吧分享");
//			data.setText("Hi~！我正在使用“踢球吧”，看球，约球，踢球，场场都精彩，你也一起来吧！");
            data.setText(shareText);
			data.setImageUrl(ShareHelper.iconUrl);
//			data.setUrl("http://www.bmob.cn/");
            data.setUrl(downloadUrl);
			share.shareToWechat(data);
		}
			break;
		case R.id.add_qq:{
			ShareData data = new ShareData();
			data.setTitle("踢球吧分享");
//			data.setText("Hi~！我正在使用“踢球吧”，看球，约球，踢球，场场都精彩，你也一起来吧！");
            data.setText(shareText);
			data.setImageUrl(ShareHelper.iconUrl);
//			data.setUrl("http://www.bmob.cn/");
            data.setUrl(downloadUrl);
			share.shareToQQ(data);
		}
			break;
		case R.id.add_friend:
			Intent intent1 = new Intent();
			intent1.setClass(mContext, AddFromFriendActivity.class);
			intent1.putExtra("team", currentTeam);
			startActivity(intent1);
			break;
		default:
			break;
		}
	}

	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
}
