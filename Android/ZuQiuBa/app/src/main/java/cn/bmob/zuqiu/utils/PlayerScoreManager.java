package cn.bmob.zuqiu.utils;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class PlayerScoreManager {
//	private Context mContext;
//
//	public PlayerScoreManager(Context mContext) {
//		super();
//		this.mContext = mContext;
//	}
//	
	public static void getPlayerScoreInTournament(Context mContext,User user,Tournament tournament,FindListener listener){

		List<BmobQuery<PlayerScore>> queries = new ArrayList<BmobQuery<PlayerScore>>();

		BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
		query.addWhereEqualTo("player", user);
		queries.add(query);

		BmobQuery<PlayerScore> query1 = new BmobQuery<PlayerScore>();
		query1.addWhereEqualTo("competition", tournament);
		queries.add(query1);

		BmobQuery<PlayerScore> total = new BmobQuery<PlayerScore>();
		total.or(queries);
		total.findObjects(mContext, listener);

	}
	
	/**
	 * 获取某球队某场比赛的球员分数
	 * @param mContext
	 * @param team
	 * @param tournament
	 * @param listener
	 */
	public static void getTeamPlayerScoreInTournament(Context mContext,Team team,Tournament tournament,String order,FindListener<PlayerScore> listener){
		
		List<BmobQuery<PlayerScore>> queries = new ArrayList<BmobQuery<PlayerScore>>();
		
		BmobQuery<PlayerScore> query1 = new BmobQuery<PlayerScore>();
		query1.addWhereEqualTo("competition", tournament);
//		query1.include("player,league,competition,team");
		queries.add(query1);
		
		BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
		query.addWhereEqualTo("team", team);
//		query.include("player,league,competition,team");
		queries.add(query);
		
		BmobQuery<PlayerScore> total = new BmobQuery<PlayerScore>();
//		total.order(order);
		total.or(queries);
		total.include("player,league,competition,team");
		total.findObjects(mContext, listener);
		
	}
	
	
	public static void getAllPlayerScore(Context mContext,FindListener<PlayerScore> listener,String order, String tournamentId, String teamId){
		BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
        Tournament t = new Tournament();
        t.setObjectId(tournamentId);
        Team team = new Team();
        team.setObjectId(teamId);
        query.addWhereEqualTo("competition", t);
        query.addWhereEqualTo("team", team);
		query.include("player,league,competition,team");
		query.order(order);
		query.findObjects(mContext, listener);
	}

}
