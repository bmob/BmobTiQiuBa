package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.share.ZuQiuShare;
import cn.bmob.zuqiu.ui.base.BaseActivity;

public class AddFriendActivity extends BaseActivity{

	private EditText searchInput;
	private ImageButton searchFriend;
	
	private RelativeLayout addPhone;
	private RelativeLayout addWechat;
	private RelativeLayout addQq;
	
	private String searchContent;
	
	private ZuQiuShare share;

    private String shareText = "";
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_add_friend);
		setUpAction(mActionBarTitle, getString(R.string.add_friend), 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		share = new ZuQiuShare(mContext);
        
        shareText = getUser().getNickname()+"邀请您加入踢球吧，与他并肩战斗。踢球吧，记录你的比赛！";
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		searchInput = (EditText)contentView.findViewById(R.id.search_input);
		searchFriend = (ImageButton)contentView.findViewById(R.id.search_friend);
		addPhone = (RelativeLayout)contentView.findViewById(R.id.add_phone);
		addWechat = (RelativeLayout)contentView.findViewById(R.id.add_wechat);
		addQq = (RelativeLayout)contentView.findViewById(R.id.add_qq);
		
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
			intent.setClass(mContext, SearchFriendActivity.class);
			intent.putExtra("search_content", searchContent);
			startActivity(intent);
			hideSoftInput(searchInput);
			break;
		case R.id.add_phone:{
			ShareData data = new ShareData();
			data.setText(shareText+ ShareHelper.downloadUrl);
			share.shareToMsg(data);
		}
			break;
		case R.id.add_wechat:{
			ShareData data = new ShareData();
			data.setTitle("踢球吧分享");
			data.setText(shareText);
			data.setImageUrl(ShareHelper.iconUrl);
			data.setUrl(ShareHelper.downloadUrl);
			share.shareToWechat(data);
		}
			break;
		case R.id.add_qq:{
			ShareData data = new ShareData();
			data.setTitle("踢球吧分享");
			data.setText(shareText);
			data.setImageUrl(ShareHelper.iconUrl);
			data.setUrl(ShareHelper.downloadUrl);
			share.shareToQQ(data);
		}
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
