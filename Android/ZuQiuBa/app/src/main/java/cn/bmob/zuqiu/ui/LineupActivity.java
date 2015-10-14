package cn.bmob.zuqiu.ui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.os.Environment;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.ImageLoader;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.datatype.BmobRelation;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.TeamMemberAdapter;
import cn.bmob.zuqiu.share.ScreenShot;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.ui.base.BaseNavigationDrawerActivity;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiu.view.views.CircleImageView;
import cn.bmob.zuqiuj.bean.Lineup;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class LineupActivity extends BaseNavigationDrawerActivity {
	private DrawerLayout mDrawerLayout;
	private ListView mDrawerList;
	private String[] mDemoTitles;

	LinearLayout person_one;
    CircleImageView icon_one;
	TextView name_one;

	LinearLayout zhongfeng_content;
	TextView zhongfeng_num;

	LinearLayout houwei_content;
	TextView houwei_num;

	LinearLayout qianfeng_content;
	TextView qiangfeng_num;

	Team currentTeam;
	TeamMemberAdapter mAdapter;
	List<User> listData = new ArrayList<User>();
	int currentIndex;//右侧列表索引
	int currentPosition;//球员索引
    CircleImageView currentIcon;
	TextView currentName;

	public static final int TYPE_QIAN_FENG = 1;
	public static final int TYPE_ZHONG_FENG = 2;
	public static final int TYPE_HOUWEI = 3;
	public static final int TYPE_GOAL_KEEPER = 4;

	int currentType = TYPE_GOAL_KEEPER;
	int number_qiangfeng = 2;
	int number_zhongfeng = 2;
	int number_houwei = 1;

	LinearLayout person_houwei_one;
	LinearLayout person_houwei_two;
	LinearLayout person_houwei_three;
	LinearLayout person_houwei_four;
	LinearLayout person_houwei_five;

    CircleImageView icon_houwei_one;
	TextView name_houwei_one;
    CircleImageView icon_houwei_two;
	TextView name_houwei_two;
    CircleImageView icon_houwei_three;
	TextView name_houwei_three;
    CircleImageView icon_houwei_four;
	TextView name_houwei_four;
    CircleImageView icon_houwei_five;
	TextView name_houwei_five;

	LinearLayout[] houweis = new LinearLayout[5];

	LinearLayout person_zhongfeng_one;
	LinearLayout person_zhongfeng_two;
	LinearLayout person_zhongfeng_three;
	LinearLayout person_zhongfeng_four;
	LinearLayout person_zhongfeng_five;

    CircleImageView icon_zhongfeng_one;
	TextView name_zhongfeng_one;
    CircleImageView icon_zhongfeng_two;
	TextView name_zhongfeng_two;
    CircleImageView icon_zhongfeng_three;
	TextView name_zhongfeng_three;
    CircleImageView icon_zhongfeng_four;
	TextView name_zhongfeng_four;
    CircleImageView icon_zhongfeng_five;
	TextView name_zhongfeng_five;

	LinearLayout[] zhongfengs = new LinearLayout[5];

	LinearLayout person_qingfeng_one;
	LinearLayout person_qingfeng_two;
	LinearLayout person_qingfeng_three;
	LinearLayout person_qingfeng_four;
	LinearLayout person_qingfeng_five;

    CircleImageView icon_qingfeng_one;
	TextView name_qingfeng_one;
    CircleImageView icon_qingfeng_two;
	TextView name_qingfeng_two;
    CircleImageView icon_qingfeng_three;
	TextView name_qingfeng_three;
    CircleImageView icon_qingfeng_four;
	TextView name_qingfeng_four;
    CircleImageView icon_qingfeng_five;
	TextView name_qingfeng_five;

	LinearLayout[] qingfengs = new LinearLayout[5];

	ArrayList<User> houwei = new ArrayList<User>(5);
	ArrayList<User> qianfeng = new ArrayList<User>(5);
	ArrayList<User> zhongfeng = new ArrayList<User>(4);
	User goalkeeper = null;
//	User oriGoalKeeper = null;
	
	BmobRelation back ;
	BmobRelation striker ;
	BmobRelation forward ;
	
	private ImageView share;
	private RelativeLayout lineupContent;
	
	@Override
	protected void onCreate(Bundle arg0) {
		// TODO Auto-generated method stub
        super.onCreate(arg0);
        currentTeam = (Team) getIntent().getSerializableExtra("team");
        
        setViewContent(R.layout.activity_zhenrong);
		setUpAction(mActionBarTitle, "阵容", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar,
				View.VISIBLE);
        if(TeamManager.isCaptain(currentTeam, getUser())){
            // 只有队长才显示提交按钮
            setUpAction(mActionBarRightMenu, "发布", 0, View.VISIBLE);
        }else{
            setUpAction(mActionBarRightMenu, "发布", 0, View.GONE);
        }
		lineupContent = (RelativeLayout)findViewById(R.id.lineup_content);
		mDemoTitles = getResources().getStringArray(
				R.array.umeng_update_demo_array);
		mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
		mDrawerList = (ListView) findViewById(R.id.left_drawer);

		mDrawerLayout.setDrawerShadow(R.drawable.drawer_shadow,
				GravityCompat.START);
		// set up the drawer's list view with items and click listener
		// mDrawerList.setAdapter(new ArrayAdapter<String>(this,
		// R.layout.drawer_list_item, ));
		mDrawerList.setOnItemClickListener(new DrawerItemClickListener());

		getTeamMembers(currentTeam);
		initMemberView();
		back = new BmobRelation();
		striker = new BmobRelation();
		forward = new BmobRelation();
	}
	
	private void initMemberView(){
		getLineup();
	}

    private Lineup curLineUp=null;//当前阵容

	private void getLineup(){
		BmobQuery<Lineup> query = new BmobQuery<Lineup>();
		query.addWhereEqualTo("team", currentTeam);
		query.include("team,goalkeeper");
		query.order("-updatedAt");
		query.findObjects(LineupActivity.this, new FindListener<Lineup>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onSuccess(List<Lineup> arg0) {
				// TODO Auto-generated method stub
//				showToast(""+arg0.size());
				if(arg0!=null&&arg0.size()>0){
					User user = arg0.get(0).getGoalkeeper();
					goalkeeper = user;
					if(user!=null){
						if(user.getNickname()!=null){
							name_one.setText(user.getNickname());
						}else{
							name_one.setText(user.getUsername());
						}
                        if(user.getAvator() != null && !TextUtils.isEmpty(user.getAvator().getFileUrl(mContext))){
                            ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext), icon_one, ImageLoadOptions.getOptions(R.drawable.bg_lineup_member_normal,-1));
                        }else{
                            icon_one.setImageResource(R.drawable.bg_lineup_member_normal);
                        }
					}
                    //当前阵容
                    curLineUp = arg0.get(0);
					getMemberByType(arg0.get(0),"back");
					getMemberByType(arg0.get(0), "striker");
					getMemberByType(arg0.get(0), "forward");
				}
			}
		});
	}
	
	
	/**
	 * 获取后卫人员
	 */
	private void getMemberByType(Lineup lineup,final String memberType){
		LogUtil.i(TAG,"ID:"+lineup.getObjectId()+memberType);
		if(lineup==null)
			return;
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo(memberType, new BmobPointer(lineup));
		query.findObjects(mContext, new FindListener<User>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onSuccess(List<User> arg0) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG, "SIZE:"+memberType+arg0.size());
				if(arg0!=null&&arg0.size()>0){
					if(memberType.equals("back")){
						houwei_num.setText(arg0.size()+"");
						number_houwei =arg0.size();
						for(int i=0;i<arg0.size();i++){
							houweis[i].setVisibility(View.VISIBLE);
							back.add(arg0.get(i));
							houwei.add(arg0.get(i));
						}
						switch (arg0.size()) {
						case 5:
							setupPerson(arg0.get(4), name_houwei_five, icon_houwei_five, R.drawable.bg_lineup_member_normal);
						case 4:
							setupPerson(arg0.get(3), name_houwei_four, icon_houwei_four, R.drawable.bg_lineup_member_normal);
						case 3:
							setupPerson(arg0.get(2), name_houwei_three, icon_houwei_three, R.drawable.bg_lineup_member_normal);
						case 2:
							setupPerson(arg0.get(1), name_houwei_two, icon_houwei_two, R.drawable.bg_lineup_member_normal);
						case 1:
							setupPerson(arg0.get(0), name_houwei_one, icon_houwei_one, R.drawable.bg_lineup_member_normal);
							break;
						}
					}else if(memberType.equals("striker")){
						number_zhongfeng = arg0.size();
						zhongfeng_num.setText(arg0.size()+"");
						for(int i=0;i<arg0.size();i++){
							zhongfengs[i].setVisibility(View.VISIBLE);
							striker.add(arg0.get(i));
							zhongfeng.add(arg0.get(i));
						}
						switch (arg0.size()) {
						case 5:
							setupPerson(arg0.get(4), name_zhongfeng_five, icon_zhongfeng_five, R.drawable.bg_lineup_member_normal);
						case 4:
							setupPerson(arg0.get(3), name_zhongfeng_four, icon_zhongfeng_four, R.drawable.bg_lineup_member_normal);
						case 3:
							setupPerson(arg0.get(2), name_zhongfeng_three, icon_zhongfeng_three, R.drawable.bg_lineup_member_normal);
						case 2:
							setupPerson(arg0.get(1), name_zhongfeng_two, icon_zhongfeng_two, R.drawable.bg_lineup_member_normal);
						case 1:
							setupPerson(arg0.get(0), name_zhongfeng_one, icon_zhongfeng_one, R.drawable.bg_lineup_member_normal);
							break;
						}
					}else if(memberType.equals("forward")){
						number_qiangfeng = arg0.size();
						qiangfeng_num.setText(arg0.size()+"");
						for(int i=0;i<arg0.size();i++){
							qingfengs[i].setVisibility(View.VISIBLE);
							forward.add(arg0.get(i));
							qianfeng.add(arg0.get(i));
						}
						switch (arg0.size()) {
						case 5:
							setupPerson(arg0.get(4), name_qingfeng_five, icon_qingfeng_five, R.drawable.bg_lineup_member_normal);
						case 4:
							setupPerson(arg0.get(3), name_qingfeng_four, icon_qingfeng_four, R.drawable.bg_lineup_member_normal);
						case 3:
							setupPerson(arg0.get(2), name_qingfeng_three, icon_qingfeng_three, R.drawable.bg_lineup_member_normal);
						case 2:
							setupPerson(arg0.get(1), name_qingfeng_two, icon_qingfeng_two, R.drawable.bg_lineup_member_normal);
						case 1:
							setupPerson(arg0.get(0), name_qingfeng_one, icon_qingfeng_one, R.drawable.bg_lineup_member_normal);
							break;
						}
					}
					
				}
			}
		});
	}
	
	private void setupPerson(User user,TextView name,final ImageView icon,final int defaultId){
		if(user!=null){
			if(user.getNickname()!=null){
				name.setText(user.getNickname());
			}else{
				name.setText(user.getUsername());
			}
            if(user.getAvator() != null && !TextUtils.isEmpty(user.getAvator().getFileUrl(mContext))){
                ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext), icon, ImageLoadOptions.getOptions(R.drawable.bg_lineup_member_normal,-1));
            }else{
                icon.setImageResource(R.drawable.bg_lineup_member_normal);
            }
		}else{
			name.setText("");
			icon.setImageResource(R.drawable.bg_lineup_member_normal);
		}
	}

	private void getTeamMembers(Team team) {
		// TODO Auto-generated method stub
		if (team == null) {
			return;
		}
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("footballer", new BmobPointer(team));
		query.findObjects(mContext, new FindListener<User>() {

			@Override
			public void onSuccess(List<User> list) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG, "size:" + list.size());
				if (list.size() != 0) {
					listData = list;
					if (mAdapter == null) {
						mAdapter = new TeamMemberAdapter(mContext, list);
						mDrawerList.addFooterView(getFooter());
						mDrawerList.setAdapter(mAdapter);
					} else {
						mAdapter.setData(list);
					}
				} else {
				}
			}

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub

			}
		});
	}

	private View getFooter(){
		View view = View.inflate(mContext, R.layout.item_zhenrong, null);
		TextView tv = (TextView)view.findViewById(R.id.member_name);
		tv.setText("清除");
		view.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				currentIcon.setImageResource(R.drawable.bg_lineup_member_normal);
				currentName.setText("名字");
				switch (currentType) {
				case TYPE_GOAL_KEEPER:
					goalkeeper = null;
					break;
				case TYPE_HOUWEI:
					if(houwei.size()>currentPosition){
						back.remove(houwei.get(currentPosition));
						houwei.remove(currentPosition);
					}
					break;
				case TYPE_QIAN_FENG:
					if(qianfeng.size()>currentPosition){
						forward.remove(qianfeng.get(currentPosition));
						qianfeng.remove(currentPosition);
					}
					break;
				case TYPE_ZHONG_FENG:
					if(zhongfeng.size()>currentPosition){
						striker.remove(zhongfeng.get(currentPosition));
						zhongfeng.remove(currentPosition);
					}
					break;
				default:
					break;
				}
                mDrawerLayout.closeDrawer(mDrawerList);
			}
		});
		return view;
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		share = (ImageView)contentView.findViewById(R.id.share_zhengrong);
		share.setOnClickListener(this);
		person_one = (LinearLayout) contentView
				.findViewById(R.id.person_goal_keeper);
		icon_one = (CircleImageView) contentView.findViewById(R.id.icon_one);
		name_one = (TextView) contentView.findViewById(R.id.name_one);

		zhongfeng_content = (LinearLayout) contentView
				.findViewById(R.id.zhongfeng_number_one);
		zhongfeng_num = (TextView) contentView.findViewById(R.id.zhongfeng_num);

		qianfeng_content = (LinearLayout) contentView
				.findViewById(R.id.zhongfeng_number_two);
		qiangfeng_num = (TextView) contentView
				.findViewById(R.id.zhongfeng_num_two);

		houwei_content = (LinearLayout) contentView
				.findViewById(R.id.zhongfeng_number_three);
		houwei_num = (TextView) contentView
				.findViewById(R.id.zhongfeng_num_three);

		person_one.setOnClickListener(this);
		zhongfeng_content.setOnClickListener(this);
		houwei_content.setOnClickListener(this);
		qianfeng_content.setOnClickListener(this);
		// 后卫
		person_houwei_one = (LinearLayout) contentView
				.findViewById(R.id.person_houwei_one);
		person_houwei_two = (LinearLayout) contentView
				.findViewById(R.id.person_houwei_two);
		person_houwei_three = (LinearLayout) contentView
				.findViewById(R.id.person_houwei_three);
		person_houwei_four = (LinearLayout) contentView
				.findViewById(R.id.person_houwei_four);
		person_houwei_five = (LinearLayout) contentView
				.findViewById(R.id.person_houwei_five);
		
		
		icon_houwei_one = (CircleImageView) contentView
				.findViewById(R.id.icon_houwei_one);
		icon_houwei_two = (CircleImageView) contentView
				.findViewById(R.id.icon_houwei_two);
		icon_houwei_three = (CircleImageView) contentView
				.findViewById(R.id.icon_houwei_three);
		icon_houwei_four = (CircleImageView) contentView
				.findViewById(R.id.icon_houwei_four);
		icon_houwei_five = (CircleImageView)contentView.findViewById(R.id.icon_houwei_five);

		name_houwei_one = (TextView) contentView
				.findViewById(R.id.name_houwei_one);
		name_houwei_two = (TextView) contentView
				.findViewById(R.id.name_houwei_two);
		name_houwei_three = (TextView) contentView
				.findViewById(R.id.name_houwei_three);
		name_houwei_four = (TextView) contentView
				.findViewById(R.id.name_houwei_four);
		name_houwei_five = (TextView) contentView
				.findViewById(R.id.name_houwei_five);

		houweis[0] = person_houwei_one;
		houweis[1] = person_houwei_two;
		houweis[2] = person_houwei_three;
		houweis[3] = person_houwei_four;
		houweis[4] = person_houwei_five;
		for (int i = 0; i < houweis.length; i++) {
			houweis[i].setOnClickListener(this);
		}
		// 中锋
		person_zhongfeng_one = (LinearLayout) contentView
				.findViewById(R.id.person_zhongfeng_one);
		person_zhongfeng_two = (LinearLayout) contentView
				.findViewById(R.id.person_zhongfeng_two);
		person_zhongfeng_three = (LinearLayout) contentView
				.findViewById(R.id.person_zhongfeng_three);
		person_zhongfeng_four = (LinearLayout) contentView
				.findViewById(R.id.person_zhongfeng_four);
		person_zhongfeng_five = (LinearLayout) contentView
				.findViewById(R.id.person_zhongfeng_five);

		icon_zhongfeng_one = (CircleImageView) contentView
				.findViewById(R.id.icon_zhongfeng_one);
		icon_zhongfeng_two = (CircleImageView) contentView
				.findViewById(R.id.icon_zhongfeng_two);
		icon_zhongfeng_three = (CircleImageView) contentView
				.findViewById(R.id.icon_zhongfeng_three);
		icon_zhongfeng_four = (CircleImageView) contentView
				.findViewById(R.id.icon_zhongfeng_four);
		icon_zhongfeng_five = (CircleImageView) contentView
				.findViewById(R.id.icon_zhongfeng_five);

		name_zhongfeng_one = (TextView) contentView
				.findViewById(R.id.name_zhongfeng_one);
		name_zhongfeng_two = (TextView) contentView
				.findViewById(R.id.name_zhongfeng_two);
		name_zhongfeng_three = (TextView) contentView
				.findViewById(R.id.name_zhongfeng_three);
		name_zhongfeng_four = (TextView) contentView
				.findViewById(R.id.name_zhongfeng_four);
		name_zhongfeng_five = (TextView) contentView
				.findViewById(R.id.name_zhongfeng_five);

		zhongfengs[0] = person_zhongfeng_one;
		zhongfengs[1] = person_zhongfeng_two;
		zhongfengs[2] = person_zhongfeng_three;
		zhongfengs[3] = person_zhongfeng_four;
		zhongfengs[4] = person_zhongfeng_five;
		for (int i = 0; i < zhongfengs.length; i++) {
			zhongfengs[i].setOnClickListener(this);
		}
		// 前锋
		person_qingfeng_one = (LinearLayout) contentView
				.findViewById(R.id.person_qingfeng_one);
		person_qingfeng_two = (LinearLayout) contentView
				.findViewById(R.id.person_qingfeng_two);
		person_qingfeng_three = (LinearLayout) contentView
				.findViewById(R.id.person_qingfeng_three);
		person_qingfeng_four = (LinearLayout) contentView
				.findViewById(R.id.person_qingfeng_four);
		person_qingfeng_five = (LinearLayout) contentView
				.findViewById(R.id.person_qingfeng_five);

		icon_qingfeng_one = (CircleImageView) contentView
				.findViewById(R.id.icon_qiangfeng_one);
		icon_qingfeng_two = (CircleImageView) contentView
				.findViewById(R.id.icon_qiangfeng_two);
		icon_qingfeng_three = (CircleImageView) contentView
				.findViewById(R.id.icon_qiangfeng_three);
		icon_qingfeng_four = (CircleImageView) contentView
				.findViewById(R.id.icon_qiangfeng_four);
		icon_qingfeng_five = (CircleImageView) contentView
				.findViewById(R.id.icon_qiangfeng_five);

		name_qingfeng_one = (TextView) contentView
				.findViewById(R.id.name_qianfeng_one);
		name_qingfeng_two = (TextView) contentView
				.findViewById(R.id.name_qianfeng_two);
		name_qingfeng_three = (TextView) contentView
				.findViewById(R.id.name_qianfeng_three);
		name_qingfeng_four = (TextView) contentView
				.findViewById(R.id.name_qianfeng_four);
		name_qingfeng_five = (TextView) contentView
				.findViewById(R.id.name_qianfeng_five);

		qingfengs[0] = person_qingfeng_one;
		qingfengs[1] = person_qingfeng_two;
		qingfengs[2] = person_qingfeng_three;
		qingfengs[3] = person_qingfeng_four;
		qingfengs[4] = person_qingfeng_five;
		for (int i = 0; i < qingfengs.length; i++) {
			qingfengs[i].setOnClickListener(this);
		}
		
		currentIcon = icon_one;
		currentName = name_one;
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		
		if(v.getId()==R.id.share_zhengrong){
			ShareData data = new ShareData();
			data.setText("阵容分享");
			data.setText("我来自一个不同凡响的球队，一起来加入我们吧！"+ShareHelper.getLineupUrl(currentTeam.getObjectId()));
			String url = ScreenShot.savePic(ScreenShot.takeScreenshotForView(lineupContent), Environment.getExternalStorageDirectory()+File.separator+"Android"+File.separator+"data"+File.separator+this.getPackageName()+File.separator+"lineup"+File.separator+System.currentTimeMillis());
			data.setImageUrl(url);
			data.setUrl(ShareHelper.getLineupUrl(currentTeam.getObjectId()));
			ShareHelper.share(LineupActivity.this, data);
			LogUtil.i("share", "lineup"+url);
		}
		if(!TeamManager.isCaptain(currentTeam, getUser())){
			showToast("只有队长才能修改阵容数据");
			return;
		}
		switch (v.getId()) {
		case R.id.person_houwei_one:
			currentType = TYPE_HOUWEI;
			currentPosition = 0;
			currentIcon = icon_houwei_one;
			currentName = name_houwei_one;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_houwei_two:
			currentType = TYPE_HOUWEI;
			currentPosition = 1;
			currentIcon = icon_houwei_two;
			currentName = name_houwei_two;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_houwei_three:
			currentType = TYPE_HOUWEI;
			currentPosition = 2;
			currentIcon = icon_houwei_three;
			currentName = name_houwei_three;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_houwei_four:
			currentType = TYPE_HOUWEI;
			currentPosition = 3;
			currentIcon = icon_houwei_four;
			currentName = name_houwei_four;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_houwei_five:
			currentType = TYPE_HOUWEI;
			currentPosition = 4;
			currentIcon = icon_houwei_five;
			currentName = name_houwei_five;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_zhongfeng_one:
			currentType = TYPE_ZHONG_FENG;
			currentPosition = 0;
			currentIcon = icon_zhongfeng_one;
			currentName = name_zhongfeng_one;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_zhongfeng_two:
			currentType = TYPE_ZHONG_FENG;
			currentPosition = 1;
			currentIcon = icon_zhongfeng_two;
			currentName = name_zhongfeng_two;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_zhongfeng_three:
			currentType = TYPE_ZHONG_FENG;
			currentPosition = 2;
			currentIcon = icon_zhongfeng_three;
			currentName = name_zhongfeng_three;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_zhongfeng_four:
			currentType = TYPE_ZHONG_FENG;
			currentPosition = 3;
			currentIcon = icon_zhongfeng_four;
			currentName = name_zhongfeng_four;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_zhongfeng_five:
			currentType = TYPE_ZHONG_FENG;
			currentPosition = 4;
			currentIcon = icon_zhongfeng_five;
			currentName = name_zhongfeng_five;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_qingfeng_one:
			currentType = TYPE_QIAN_FENG;
			currentPosition = 0;
			currentIcon = icon_qingfeng_one;
			currentName = name_qingfeng_one;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_qingfeng_two:
			currentType = TYPE_QIAN_FENG;
			currentPosition = 1;
			currentIcon = icon_qingfeng_two;
			currentName = name_qingfeng_two;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_qingfeng_three:
			currentType = TYPE_QIAN_FENG;
			currentPosition = 2;
			currentIcon = icon_qingfeng_three;
			currentName = name_qingfeng_three;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_qingfeng_four:
			currentType = TYPE_QIAN_FENG;
			currentPosition = 3;
			currentIcon = icon_qingfeng_four;
			currentName = name_qingfeng_four;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_qingfeng_five:
			currentType = TYPE_QIAN_FENG;
			currentPosition = 0;
			currentIcon = icon_qingfeng_five;
			currentName = name_qingfeng_five;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.person_goal_keeper:
			currentType = TYPE_GOAL_KEEPER;
			currentIcon = icon_one;
			currentName = name_one;
			mDrawerLayout.openDrawer(mDrawerList);
			break;
		case R.id.zhongfeng_number_one:
			currentType = TYPE_ZHONG_FENG;
			showPointDialog(currentType);
			break;
		case R.id.zhongfeng_number_two:
			currentType = TYPE_QIAN_FENG;
			showPointDialog(currentType);
			break;
		case R.id.zhongfeng_number_three:
			currentType = TYPE_HOUWEI;
			showPointDialog(currentType);
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

	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
		if(!TeamManager.isCaptain(currentTeam, getUser())){
			showToast("只有队长才能修改阵容数据。");
			return;
		}
        initProgressDialog(R.string.loading);
        Lineup lineup = new Lineup();
        lineup.setTeam(currentTeam);
        if (goalkeeper==null) {
            // 赵老师要求，守门员可以不设置，故取消以下两行代码
//			showToast("请设置守门员");
//			return;
        }else{
            lineup.setGoalkeeper(goalkeeper);
        }
        lineup.setBack(back);
        lineup.setStriker(striker);
        lineup.setForward(forward);
        if(curLineUp==null){//不存在阵容信息就保存
            lineup.save(mContext, new SaveListener() {

                @Override
                public void onSuccess() {
                    // TODO Auto-generated method stub
                    showToast("已发布新阵容");
                    notifyMembers();
                }

                @Override
                public void onFailure(int arg0, String arg1) {
                    // TODO Auto-generated method stub
                    showToast("发布新阵容失败");
                    dismissDialog();
                }
            });
        }else{//存在就更新阵容
            lineup.update(mContext, curLineUp.getObjectId(), new UpdateListener() {

                @Override
                public void onSuccess() {
                    // TODO Auto-generated method stub
                    showToast("已发布新阵容");
                    notifyMembers();
                }

                @Override
                public void onFailure(int arg0, String arg1) {
                    // TODO Auto-generated method stub
                    showToast("发布新阵容失败");
                    dismissDialog();
                }
            });
        }
	}

    // 给球队每位成员发送一条更新阵容的消息
    private void notifyMembers(){
        //获取指定球队的所有队员
        TeamManager.getMember(mContext,currentTeam,new FindListener<User>() {
            @Override
            public void onSuccess(List<User> users) {
                if(users!=null && users.size()>0){
                    int size = users.size();
                    for(int i=0;i<size;i++){
                        PushMessage msg = PushMessageHelper.lineupPublishMessage(LineupActivity.this,currentTeam);
                        MyApplication.getInstance().getPushHelper2().push2User(users.get(i),msg);
                    }
                }
            }
            @Override
            public void onError(int i, String s) {
                LogUtil.i("push","获取球队所有的成员信息失败...");
            }
        });

        dismissDialog();
        setResult(RESULT_OK);
        finish();
    }

	/* The click listner for ListView in the navigation drawer */
	private class DrawerItemClickListener implements
			ListView.OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position,
				long id) {
			if(!TeamManager.isCaptain(currentTeam, getUser())){
				showToast("只有队长才能修改阵容数据。");
				return;
			}
			selectItem(position);
		}
	}

	private void selectItem(int position) {
		mDrawerList.setItemChecked(position, true);
		currentIndex = position;
		User user = listData.get(position);
		for(int i=0;i<qianfeng.size();i++){
			if(qianfeng.contains(user)){
				showToast("该队员已经在场上，请重新选择");
				return;
			}
		}
		
		for(int i=0;i<zhongfeng.size();i++){
			if(zhongfeng.contains(user)){
				showToast("该队员已经在场上，请重新选择");
				return;
			}
		}
		
		for(int i=0;i<houwei.size();i++){
			if(houwei.contains(user)){
				showToast("该队员已经在场上，请重新选择");
				return;
			}
		}
		
		if(goalkeeper!=null){
			if(goalkeeper.getObjectId().equals(user.getObjectId())){
				showToast("该队员已经在场上，请重新选择");
				return;
			}
		}
		
//		showToast("type"+currentType);
		switch (currentType) {
		case TYPE_QIAN_FENG:
			if(qianfeng.size()<=currentPosition){
				qianfeng.add(user);
				forward.add(user);
			}else{
				qianfeng.set(currentPosition, user);
				forward.remove(qianfeng.get(currentPosition));
				forward.add(user);
			}
			LogUtil.i(TAG,"qian size:"+qianfeng.size());
//			showToast("qian size:"+qianfeng.size());
			break;
		case TYPE_HOUWEI:
			if(houwei.size()<=currentPosition){
				houwei.add(user);
				back.add(user);
			}else{
				houwei.set(currentPosition, user);
				back.remove(houwei.get(currentPosition));
				back.add(user);
			}
			LogUtil.i(TAG,"qian size:"+houwei.size());
//			showToast("houwei size:"+houwei.size());
			break;
		case TYPE_ZHONG_FENG:
			if(zhongfeng.size()<=currentPosition){
				zhongfeng.add(user);
				striker.add(user);
			}else{
				zhongfeng.set(currentPosition, user);
				striker.remove(zhongfeng.get(currentPosition));
				striker.add(user);
			}
			LogUtil.i(TAG,"qian size:"+zhongfeng.size());
//			showToast("zhongfeng size:"+zhongfeng.size());
			break;
		case TYPE_GOAL_KEEPER:
			goalkeeper = user;
			break;
		}
		if (user.getNickname() != null) {
			currentName.setText(user.getNickname());
		} else {
			currentName.setText(user.getUsername());
		}
        if(user.getAvator() != null && !TextUtils.isEmpty(user.getAvator().getFileUrl(mContext))){
            ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext), currentIcon, ImageLoadOptions.getOptions(R.drawable.bg_lineup_member_normal,-1));
        }else{
            currentIcon.setImageResource(R.drawable.bg_lineup_member_normal);
        }

		mDrawerLayout.closeDrawer(mDrawerList);
	}
	
	private String[] numberOfQiangFeng = { "0","1","2", "3", "4" };
	private String[] numberOfZhongFeng = { "0","1","2", "3", "4", "5" };
	private String[] numberOfHouWei = { "0","1","2", "3", "4", "5" };
	Dialog timeDialog = null;
	String[] numbers = null;

	private void showPointDialog(final int memberType) {
		if (timeDialog == null) {
			timeDialog = new AlertDialog.Builder(mContext).create();
		}
		timeDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(mContext).inflate(
				R.layout.dialog_choose_point, null);
		timeDialog.show();
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.BOTTOM);
		timeDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth(),
				LayoutParams.WRAP_CONTENT);

		ListView list = (ListView) view.findViewById(R.id.point_list);
		TextView title = (TextView) view.findViewById(R.id.choose_title);
		if (memberType == TYPE_QIAN_FENG) {
			numbers = numberOfQiangFeng;
			title.setText("选择前锋人数");
		} else if (memberType == TYPE_ZHONG_FENG) {
			numbers = numberOfZhongFeng;
			title.setText("选择中锋人数");
		} else if (memberType == TYPE_HOUWEI) {
			numbers = numberOfHouWei;
			title.setText("选择后卫人数");
		}

		list.setAdapter(new ArrayAdapter<String>(mContext,
				R.layout.item_a_text, R.id.point_num, numbers));
		list.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				if (memberType == TYPE_QIAN_FENG) {
					qiangfeng_num.setText(numbers[position]);
					number_qiangfeng = Integer.parseInt(numbers[position]);
					for (int i = 0; i < 5; i++) {
						if (i < number_qiangfeng) {
							qingfengs[i].setVisibility(View.VISIBLE);
						} else {
							qingfengs[i].setVisibility(View.GONE);
						}

					}
				} else if (memberType == TYPE_ZHONG_FENG) {
					zhongfeng_num.setText(numbers[position]);
					number_zhongfeng = Integer.parseInt(numbers[position]);
					for (int i = 0; i < 5; i++) {
						LogUtil.i("zhenrong", "" + i);
						if (i < number_zhongfeng) {
							zhongfengs[i].setVisibility(View.VISIBLE);
						} else {
							zhongfengs[i].setVisibility(View.GONE);
						}

					}
				} else if (memberType == TYPE_HOUWEI) {
					houwei_num.setText(numbers[position]);
					number_houwei = Integer.parseInt(numbers[position]);
					for (int i = 0; i < 5; i++) {
						if (i < number_houwei) {
							houweis[i].setVisibility(View.VISIBLE);
						} else {
							houweis[i].setVisibility(View.GONE);
						}

					}
				}
				if (timeDialog != null && timeDialog.isShowing()) {
					timeDialog.dismiss();
				}
			}
		});
	}
}
