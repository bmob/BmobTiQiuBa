/*
 * Copyright 2013 David Schreiber
 *           2013 John Paul Nalog
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package cn.bmob.zuqiu.ui;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import java.util.List;

import at.technikum.mti.fancycoverflow.FancyCoverFlow;
import at.technikum.mti.fancycoverflow.FancyCoverFlowAdapter;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.PlayScoreAdapter;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.share.ShareHelper;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PlayerScoreManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.TournamentHelper;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
/*
* 比赛报告
* */
public class ViewGroupExample extends BaseActivity {

    // =============================================================================
    // Supertype overrides
    // =============================================================================
	FancyCoverFlow fancyCoverFlow ;
	List<PlayerScore> shoters;
	List<PlayerScore> assists;
	List<PlayerScore> attend;
	
	private Tournament mTournament;
	
	private PushMessage msg ;
	
	private TextView homePoint;
	private TextView oppoPoint;
	private TextView homeName;
	private TextView oppoName;
	private TextView compeTime;
	private TextView compeSite;
	private TextView nameAndNature;
	private ImageView reportShare;

    private String tournamentId;
    private String teamId;
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setViewContent(R.layout.activity_report);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
        setUpAction(mActionBarTitle, "比赛报告", 0, View.VISIBLE);

        msg = (PushMessage) getIntent().getSerializableExtra("msg");

        tournamentId = msg.getTargetId().split("&")[0];
        teamId = msg.getTargetId().split("&")[1];
        
        fancyCoverFlow = (FancyCoverFlow) findViewById(R.id.fancyCoverFlow);
        fancyCoverFlow.setSpacing(-180);

        getTournament(tournamentId);
//        initProgressDialog(R.string.loading);
        PlayerScoreManager.getAllPlayerScore(this, new FindListener<PlayerScore>() {

    				@Override
    				public void onError(int arg0, String arg1) {
    					// TODO Auto-generated method stub
//    					dismissDialog();
    				}

    				@Override
    				public void onSuccess(List<PlayerScore> arg0) {
    					// TODO Auto-generated method stub
    					LogUtil.i("size","size:"+arg0.size());
//    					dismissDialog();
    					shoters = arg0;
    					if(shoters!=null&&assists!=null&&attend!=null){
    						fancyCoverFlow.setAdapter(new ViewGroupExampleAdapter());
    					}
    			        
    				}

    			},"-goals", tournamentId, teamId);
        PlayerScoreManager.getAllPlayerScore(this, new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
			}

			@Override
			public void onSuccess(List<PlayerScore> arg0) {
				// TODO Auto-generated method stub
				LogUtil.i("size","size:"+arg0.size());
				dismissDialog();
				assists = arg0;
				if(shoters!=null&&assists!=null&&attend!=null){
					fancyCoverFlow.setAdapter(new ViewGroupExampleAdapter());
				}
			}
		},"-assists", tournamentId, teamId);
        PlayerScoreManager.getAllPlayerScore(this, new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
			}

			@Override
			public void onSuccess(List<PlayerScore> arg0) {
				// TODO Auto-generated method stub
				LogUtil.i("size","size:"+arg0.size());
				dismissDialog();
				attend = arg0;
				if(shoters!=null&&assists!=null&&attend!=null){
					fancyCoverFlow.setAdapter(new ViewGroupExampleAdapter());
				}
			}
		},"-assists", tournamentId, teamId);
    }

    private void getTournament(String tournamentId){
    	initProgressDialog(R.string.loading);
    	BmobQuery<Tournament> query = new BmobQuery<Tournament>();
    	query.include("home_court,opponent,league");

    	query.getObject(mContext, tournamentId, new GetListener<Tournament>() {
			
			@Override
			public void onSuccess(Tournament arg0) {
				// TODO Auto-generated method stub
				dismissDialog();
				mTournament = arg0;
				initViews(arg0);
			}
			
			@Override
			public void onFailure(int arg0, String arg1) {
				// TODO Auto-generated method stub
				dismissDialog();
			}
		});
    }
    
    private void initViews(Tournament t){
    	LogUtil.i("http",t.toString());
    	LogUtil.i("http","t:"+(t==null));
    	LogUtil.i("http","h:"+(t.getScore_h()==null));
    	LogUtil.i("http","h2:"+(t.getScore_h2()==null));
    	LogUtil.i("http","homepoint:"+(homePoint==null));
    	homePoint.setText(t.getScore_h()==null?"0":t.getScore_h());
    	oppoPoint.setText(t.getScore_h2()==null?"0":t.getScore_h2());
    	homeName.setText(t.getHome_court().getName());
    	oppoName.setText(t.getOpponent().getName());
    	compeSite.setText(t.getSite());
    	if(t.getLeague()==null){
    		nameAndNature.setText(TournamentHelper.getNature(t.getNature()));
    	}else{
    		nameAndNature.setText(t.getLeague().getName()+"-"+TournamentHelper.getNature(t.getNature()));
    	}
    	compeTime.setText(TimeUtils.getTimeByBmobDate(t.getStart_time()));
    }
    
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		homePoint = (TextView)contentView.findViewById(R.id.report_home_point);
		oppoPoint= (TextView)contentView.findViewById(R.id.report_oppo_point);
		homeName= (TextView)contentView.findViewById(R.id.report_home_name);
		oppoName= (TextView)contentView.findViewById(R.id.report_oppo_name);
		compeTime= (TextView)contentView.findViewById(R.id.report_time);
		compeSite= (TextView)contentView.findViewById(R.id.report_site);
		nameAndNature= (TextView)contentView.findViewById(R.id.report_nature);
        reportShare = (ImageView)contentView.findViewById(R.id.report_share);
        reportShare.setOnClickListener(this);
	}
    
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.report_share:
			if(mTournament!=null){
				ShareData data = new ShareData();
				data.setTitle("足球吧比赛报告");
				data.setImageUrl(ShareHelper.iconUrl);
				List<Team> teams = MyApplication.getInstance().getTeams();
				Team currentTeam = mTournament.getHome_court();
				for(int i=0;i<teams.size();i++){
					if(teams.get(i).getObjectId().equals(mTournament.getHome_court().getObjectId())){
						currentTeam = mTournament.getHome_court();
						break;
					}else if(teams.get(i).getObjectId().equals(mTournament.getOpponent().getObjectId())){
						currentTeam = mTournament.getOpponent();
						break;
					}
				}
				data.setText("昨天已经过去，未来继续拼搏，"+mTournament.getName()+"比赛圆满结束了，我们一起来看精彩记录吧！"+
						ShareHelper.getCompetitionReport(mTournament.getObjectId(), currentTeam.getObjectId()));
				data.setUrl(ShareHelper.getCompetitionReport(mTournament.getObjectId(), currentTeam.getObjectId()));
				ShareHelper.share(ViewGroupExample.this, data);
			}
			break;

		default:
			break;
		}
	}
	
	private List<PlayerScore> getScores(){
		return shoters;
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
	
    /**
     * 获取屏幕宽高
     * @return
     */
    public static int[] getScreenSize() {
        int[] screens;
        // if (Constants.screenWidth > 0) {
        // return screens;
        // }
        DisplayMetrics dm=new DisplayMetrics();
        dm=MyApplication.getInstance().getResources().getDisplayMetrics();
        screens=new int[]{dm.widthPixels, dm.heightPixels};
        return screens;
    }
	
    // Private classes
    // ============================================================================
    // =============================================================================

    private class ViewGroupExampleAdapter extends FancyCoverFlowAdapter {

        // =============================================================================
        // Private members
        // =============================================================================
//    	private List<PlayerScore> data;
//    	
//    	public ViewGroupExampleAdapter(List<PlayerScore> data){
//    		this.data = data;
//    	}

        // =============================================================================
        // Supertype overrides
        // =============================================================================

        @Override
        public int getCount() {
            return 3;
        }

        @Override
        public Object getItem(int i) {
            return i;
        }

        @Override
        public long getItemId(int i) {
            return i;
        }

        @Override
        public View getCoverFlowItem(int i, View reuseableView, ViewGroup viewGroup) {
            CustomViewGroup customViewGroup = null;

            if (reuseableView != null) {
                customViewGroup = (CustomViewGroup) reuseableView;
            } else {
                customViewGroup = new CustomViewGroup(viewGroup.getContext());
                int width = getScreenSize()[0];
                int height = getScreenSize()[1];
                customViewGroup.setLayoutParams(new FancyCoverFlow.LayoutParams(width*2/3, height/2));
            }
            switch (i) {
			case 0:
				customViewGroup.getTextView().setText("射手榜");
				customViewGroup.setAdapter(new PlayScoreAdapter(customViewGroup.getContext(), shoters));
				break;
			case 1:
				customViewGroup.getTextView().setText("助攻榜");
				customViewGroup.setAdapter(new PlayScoreAdapter(customViewGroup.getContext(), assists));
				break;
			case 2:
				customViewGroup.getTextView().setText("出场名单");
				customViewGroup.setAdapter(new PlayScoreAdapter(customViewGroup.getContext(), attend));
				break;
			}
            	 
           
            
            return customViewGroup;
        }
    }

    public static class CustomViewGroup extends LinearLayout {

        // =============================================================================
        // Child views
        // =============================================================================

        private TextView textView;
        private ListView listview;
        private View view;
        // =============================================================================
        // Constructor
        // =============================================================================

        private CustomViewGroup(Context context) {
            super(context);

            this.setOrientation(VERTICAL);
            this.setBackgroundResource(R.drawable.bg_score_order);
            this.setPadding(8, 8, 8, 8);
            this.textView = new TextView(context);
            this.listview = new ListView(context);
            this.view = new View(context);

            LinearLayout.LayoutParams layoutParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            this.textView.setLayoutParams(layoutParams);
            this.listview.setLayoutParams(layoutParams);
            LinearLayout.LayoutParams layoutParams2 = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1);
            this.view.setLayoutParams(layoutParams2);
            
            this.textView.setGravity(Gravity.LEFT);
            this.textView.setPadding(8, 8, 8, 8);
            this.textView.setTextColor(Color.parseColor("#ffffff"));

            this.listview.setCacheColorHint(Color.parseColor("#00000000"));
            this.listview.setDividerHeight(0);
            this.listview.setVerticalScrollBarEnabled(false);
            
            this.view.setBackgroundColor(Color.parseColor("#ffffff"));
            
            this.addView(this.textView);
            this.addView(this.view);
            this.addView(this.listview);
        }

        // =============================================================================
        // Getters
        // =============================================================================

        private TextView getTextView() {
            return textView;
        }

        private ListView getListView(){
        	return listview;
        }
        
        private void setAdapter(BaseAdapter adapter){
        	listview.setAdapter(adapter);
        }
    }


}
