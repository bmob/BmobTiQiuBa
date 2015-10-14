package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.SheShouAdapter;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.LeaguePlayerStat;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.User;

public class SheShouFragment extends BaseFragment{
	ListView sheshouList ;
	SheShouAdapter mAdapter;
	List<LeaguePlayerStat> data = new ArrayList<LeaguePlayerStat>();
	User user ;
    static League league;
	public static SheShouFragment getInstance(int pos, League l){
		SheShouFragment jifen = new SheShouFragment();
        league = l;
		return jifen;
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		user = BmobUser.getCurrentUser(getActivity(), User.class);
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
        getLeaguePlayerStatList(league);
		return inflater.inflate(R.layout.fragment_sheshou, null);
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onViewCreated(view, savedInstanceState);
		sheshouList = (ListView)findViewById(R.id.sheshou_list);
	}
    /*
    * 射手榜单
    * */
    private void getLeaguePlayerStatList(League league){
        BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
        query.addWhereEqualTo("league", league);
        query.include("player,team");
        query.order("-goals");
        query.findObjects(getActivity(), new FindListener<PlayerScore>() {
            @Override
            public void onSuccess(List<PlayerScore> playerScores) {
              if(playerScores!=null && playerScores.size()>0){
                  mAdapter = new SheShouAdapter(getActivity(), playerScores);
                  sheshouList.setAdapter(mAdapter);
              }
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }

}
