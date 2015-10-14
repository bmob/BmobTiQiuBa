package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.SearchLeagueAdapter;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.view.views.DeletableEditText;
import cn.bmob.zuqiu.view.views.DeletableEditText.OnTextChangedListener;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

/*
* 赛事
*
* */
public class CompetitionFragment extends BaseFragment{

	private LinearLayout leagueLayout;
	private TextView leagueRecord;
	
	private LinearLayout leagueInfo;
	private TextView leagueName;
	private TextView yourTips;
	
	private ListView leagueList;
	
	private String searchContent;
	
	private List<League> leagueData = new ArrayList<League>();
	private List<League> origin = new ArrayList<League>();

	private SearchLeagueAdapter mAdapter;
	
	private League currentLeague;
	
	private DeletableEditText input;
	
	private TextView nearby_league;

    private LinearLayout layout_other;

    private ListView serarch_list;
    @Override
    public void onAttach(Activity activity) {
        // TODO Auto-generated method stub
        super.onAttach(activity);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        View v = inflater.inflate(R.layout.fragment_competition, container, false);
        return v;
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        // TODO Auto-generated method stub
        super.onHiddenChanged(hidden);
    }

    @Override
    public void onPause() {
        // TODO Auto-generated method stub
        super.onPause();
        MobclickAgent.onPageEnd(this.getClass().getSimpleName());
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        MobclickAgent.onPageStart(this.getClass().getSimpleName()); //统计页面
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onViewCreated(view, savedInstanceState);
        setUpTitle(getString(R.string.main_menu_competition));

        input = (DeletableEditText)findViewById(R.id.league_search);
        serarch_list = (ListView)findViewById(R.id.search_list);

        serarch_list.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,int position, long id) {
                // TODO Auto-generated method stub
                Intent intent = new Intent();
                intent.setClass(getActivity(), LeagueDetailActivity.class);
                intent.putExtra("league", leagueData.get(position));
                startActivity(intent);
                hideSoftInput();
                input.setText("");
                layout_other.setVisibility(View.VISIBLE);
                serarch_list.setVisibility(View.GONE);
            }
        });

        input.setOnTextChangedListener(new OnTextChangedListener() {

            @Override
            public void onTextChanged(boolean isVisible) {
                // TODO Auto-generated method stub
                if(isVisible){
                    layout_other.setVisibility(View.GONE);
                    serarch_list.setVisibility(View.VISIBLE);
                    searchLeague(input.getText().toString().trim());
                }else{
                    if(mAdapter!=null){
                        mAdapter.setTeams(origin);
                        mAdapter.notifyDataSetChanged();
                    }
                    layout_other.setVisibility(View.VISIBLE);
                    serarch_list.setVisibility(View.GONE);
                }
            }
        });

        layout_other = (LinearLayout)findViewById(R.id.layout_other);

        //显示正在参与的赛事
        leagueLayout = (LinearLayout)findViewById(R.id.saishi_info);
        leagueRecord = (TextView)findViewById(R.id.saishi_info_tips);
        leagueInfo = (LinearLayout)findViewById(R.id.saishi_tips);
        leagueName = (TextView)findViewById(R.id.saishi_name);
        yourTips = (TextView)findViewById(R.id.your_tips);

        leagueList = (ListView)findViewById(R.id.league_list);
        nearby_league = (TextView)findViewById(R.id.nearby_league);

        leagueList.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,int position, long id) {
                // TODO Auto-generated method stub
                Intent intent = new Intent();
                intent.setClass(getActivity(), LeagueDetailActivity.class);
                intent.putExtra("league", origin.get(position));
                startActivity(intent);
            }
        });

        leagueLayout.setOnClickListener(this);
        leagueRecord.setOnClickListener(this);
        leagueInfo.setOnClickListener(this);

        getLeague();
        getNearLeague();
    }
    /*
    * 附近的联赛
    * */
    private void getNearLeague(){
    	BmobQuery<League> query = new BmobQuery<League>();
        String city = BmobUser.getCurrentUser(getActivity(), User.class).getCity();
        if(!TextUtils.isEmpty(city)&& city.length()>4){
            String cityPrefix =city.substring(0,4);
            query.addWhereStartsWith("city",cityPrefix);
            query.include("master");
            query.setLimit(1000);
            query.order("-createdAt");
            query.findObjects(getActivity(), new FindListener<League>() {

                @Override
                public void onError(int arg0, String arg1) {
                    // TODO Auto-generated method stub
                    showToast("附近暂无联赛");
                }

                @Override
                public void onSuccess(List<League> arg0) {
                    // TODO Auto-generated method stub
                    if(arg0!=null&&arg0.size()>0){
                        origin = arg0;
                        mAdapter = new SearchLeagueAdapter(getActivity(), origin);
                        leagueList.setAdapter(mAdapter);
                    }
                }
            });
        }else{
            showToast("附近暂无联赛");
        }
    }
    
    
    /**
	 * 获取我正在参加的比赛
	 */
	private void getLeague(){
		if(MyApplication.getInstance().getCurrentTeam()==null){
			LogUtil.i(TAG,"TEAM IS NULL");
            leagueLayout.setVisibility(View.GONE);
            return;
        }
        LogUtil.i("league","当前队："+MyApplication.getInstance().getCurrentTeam().getName());
        //查询赛事表中主队为我当前的球队
        BmobQuery<Tournament> eq1 = new BmobQuery<Tournament>();
        eq1.addWhereEqualTo("home_court", MyApplication.getInstance().getCurrentTeam());
        //查询赛事表中客队为我当前的球队

        BmobQuery<Tournament> eq2 = new BmobQuery<Tournament>();
        eq2.addWhereEqualTo("opponent", MyApplication.getInstance().getCurrentTeam());
        //复合或查询
        List<BmobQuery<Tournament>> ors = new ArrayList<BmobQuery<Tournament>>();
        ors.add(eq1);
        ors.add(eq2);

        //复合与查询
        BmobQuery<Tournament> and1 = new BmobQuery<Tournament>();
        and1.addWhereExists("league");
        BmobQuery<Tournament> and2 = new BmobQuery<Tournament>();
        and2.addWhereNotEqualTo("league","");
        List<BmobQuery<Tournament>> ands = new ArrayList<BmobQuery<Tournament>>();
        ands.add(and1);
        ands.add(and2);

        BmobQuery<Tournament> mainQuery = new BmobQuery<Tournament>();
        mainQuery.include("league");
        mainQuery.addWhereExists("start_time");
        mainQuery.order("-start_time");
        mainQuery.and(ands);
        mainQuery.or(ors);
        mainQuery.setLimit(1000);
        mainQuery.findObjects(getActivity(),new FindListener<Tournament>() {
            @Override
            public void onSuccess(List<Tournament> arg0) {
                for(int i=0;i<arg0.size();i++){
                    LogUtil.i("league", "name:"+arg0.get(i).getName());
                }
                if(arg0!=null&&arg0.size()>0){
                    currentLeague = arg0.get(0).getLeague();
                    yourTips.setVisibility(View.VISIBLE);
                    leagueName.setText(currentLeague.getName());
                }else{
                    yourTips.setVisibility(View.GONE);
                    leagueName.setText("暂无数据");
                }
            }

            @Override
            public void onError(int arg0, String arg1) {
                LogUtil.i("league", "not FINDED:"+arg0+arg1);
                yourTips.setVisibility(View.GONE);
                leagueName.setText("暂无数据");
            }
        });
	}

    @Override
    public void onClick(View v) {
    	// TODO Auto-generated method stub
    	super.onClick(v);
    	switch (v.getId()) {
        case R.id.saishi_tips:
            if(currentLeague!=null) {
                Intent intent = new Intent();
                intent.setClass(getActivity(), LeagueRecordActivity.class);
                startActivity(intent);
            }
            break;
		default:
			break;
		}
    }
    
    /**
     * 
     * @param name
     */
    private void searchLeague(String name){
    	BmobQuery<League> leagueQuery = new BmobQuery<League>();
    	leagueQuery.addWhereContains("name", name);
    	leagueQuery.findObjects(getActivity(), new FindListener<League>() {
			
			@Override
			public void onSuccess(List<League> list) {
				// TODO Auto-generated method stub
				if(list.size()>0){
					showToast(""+list.size());
					leagueData = list;
				}else{
                    leagueData.clear();
					showToast("没有找到相关球队。");
				}
                mAdapter = new SearchLeagueAdapter(getActivity(), leagueData);
                serarch_list.setAdapter(mAdapter);
			}
			
			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("请检查网络连接。");
			}
		});
    }

    
	private void hideSoftInput(){
		InputMethodManager imm = (InputMethodManager)getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);  
		imm.hideSoftInputFromWindow(input.getWindowToken(), 0);
	}
}
