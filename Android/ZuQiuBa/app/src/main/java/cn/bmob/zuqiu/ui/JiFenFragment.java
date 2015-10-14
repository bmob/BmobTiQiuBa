package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.JiFenAdapter;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiuj.bean.Group;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.LeagueScoreStat;
import cn.bmob.zuqiuj.bean.Team;

/**
 * 联赛积分榜
 */
public class JiFenFragment extends BaseFragment{

	ListView mListView;
    JiFenAdapter mAdapter;
    static League league;
	
	public static JiFenFragment getInstance(int pos, League l){
		JiFenFragment jifen = new JiFenFragment();
        league = l;
		return jifen;
	}
	
	@Override
	public void onAttach(Activity activity) {
		// TODO Auto-generated method stub
		super.onAttach(activity);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
        getAllGroup();
		return inflater.inflate(R.layout.fragment_jifen, null);
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onViewCreated(view, savedInstanceState);
        mListView = (ListView)findViewById(R.id.jifen_list);
	}

    /*
    * 获取分组信息
    * */
    private void getAllGroup(){
        initProgressDialog("正在查询中...");
        BmobQuery<Group> query = new BmobQuery<Group>();
        query.addWhereEqualTo("league", league);
        query.findObjects(getActivity(), new FindListener<Group>() {
            @Override
            public void onSuccess(List<Group> groups) {
                Map<String,String> map = new HashMap<String, String>();
                List<LeagueScoreStat> lss = new ArrayList<LeagueScoreStat>();
                if(groups.size()>0){
                    getTeams(0,groups,map,lss);
                }else{
                    showToast("联赛积分信息暂时还未公布");
                    dismissDialog();
                }
            }

            @Override
            public void onError(int i, String s) {
                dismissDialog();
                showToast("联赛积分信息查询失败");
            }
        });
    }

    /*
    * 获取每个分组下面的球队
    * */
    private void getTeams(int index,List<Group> groups,Map<String,String> map,final List<LeagueScoreStat> lss){
        int len = groups.size();
        if(index+1<len){
            getGroupByIndex(false,index,groups,map,lss);
        }else{
            getGroupByIndex(true,index,groups,map,lss);
        }
    }

    private void getGroupByIndex(final boolean isFinish,final int index,final List<Group> groups,final Map<String,String> map,final List<LeagueScoreStat> lss){
        final Group group = groups.get(index);
        BmobQuery<Team> query = new BmobQuery<Team>();
        query.addWhereRelatedTo("teams", new BmobPointer(groups.get(index)));
        query.findObjects(getActivity(), new FindListener<Team>() {
            @Override
            public void onSuccess(List<Team> teams) {
                if(teams.size()>0){
                    for (Team t : teams){
                        map.put(t.getObjectId(),group.getName());
                    }
                    //使用迭代的方式逐个获取
                    getLeagueScoreStatList(isFinish,index,groups,map,lss);
                }else{
                    showToast("联赛积分信息暂时还未公布");
                    dismissDialog();
                }
            }

            @Override
            public void onError(int i, String s) {
                dismissDialog();
                showToast("联赛积分信息查询失败");
            }
        });
    }

    /*
    * 查询联赛积分记录
    * */
    private void getLeagueScoreStatList(final boolean isFinish,final int index,final List<Group> groups,final Map<String,String> map,final List<LeagueScoreStat> lss){
        BmobQuery<LeagueScoreStat> query = new BmobQuery<LeagueScoreStat>();
        query.addWhereEqualTo("league", league);
        query.include("team");
        query.order("-points,goalsAgainst");//先按积分降序排列，积分相同按照净胜球排列
        query.findObjects(getActivity(), new FindListener<LeagueScoreStat>() {
            @Override
            public void onSuccess(List<LeagueScoreStat> leagueScoreStats) {
                if(leagueScoreStats.size()>0){
                    int size = leagueScoreStats.size();
                    // 分组
                    int j=0;
                    for(int i=0;i<size;i++){
                        LeagueScoreStat ls = leagueScoreStats.get(i);
                        String key = ls.getTeam().getObjectId();
                        if(map.containsKey(key)){
                            j++;
                            ls.setGroupName(map.get(key));
                            ls.setIndex(j);
                            lss.add(ls);
                        }
                    }
                    if(!isFinish){//没有完成就继续
                        map.clear();
                        getTeams(index+1,groups,map,lss);
                    }else{
                        dismissDialog();
                        mAdapter = new JiFenAdapter(getActivity(), lss);
                        mListView.setAdapter(mAdapter);
                    }
                }else{
                    dismissDialog();
                    showToast("暂无联赛积分信息");
                }
            }
            @Override
            public void onError(int i, String s) {
                dismissDialog();
                showToast("联赛积分信息查询失败");
            }
        });
    }

}
