package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.text.TextUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;


public class CompetitionManager {
    private Context mContext;

    public CompetitionManager(Context mContext) {
        super();
        this.mContext=mContext;
    };
    
    private void getAllCompetitions(FindListener findListener){
        BmobQuery<Tournament> query = new BmobQuery<Tournament>();
        query.findObjects(mContext, findListener);
    }
    
    public void getNearCompetition(String cityCode,FindListener<Tournament> findListener){
    	if(TextUtils.isEmpty(cityCode)){
    		return;
    	}
    	BmobQuery<Tournament> query = new BmobQuery<Tournament>();
    	 query.addWhereEqualTo("city", cityCode);
    	 query.include("home_court,opponent");
        query.addWhereGreaterThan("event_date", new BmobDate(new Date(System.currentTimeMillis())));
    	 query.order("event_date");
         query.findObjects(mContext, findListener);
    }
    
    /**
     * 
     * @Title:        getLastCompetition 
     * @Description:  上一场
     * @param:        @param findLister    
     * @return:       void    
     * @throws 
     * @author        kingofglory
     * @Date          2014-9-3 上午9:19:04
     */
    public void getLastCompetition(List<Team> teams,FindListener findListener){
        List<BmobQuery<Tournament>> queries = new ArrayList<BmobQuery<Tournament>>();
        if(teams!=null && teams.size()>0){
            for(int i=0;i<teams.size();i++){
                BmobQuery<Tournament> query = new BmobQuery<Tournament>();
                query.addWhereEqualTo("home_court", teams.get(i));
                query.addWhereLessThan("start_time", new BmobDate(new Date()));
                queries.add(query);
            }
            for(int i=0;i<teams.size();i++){
                BmobQuery<Tournament> query = new BmobQuery<Tournament>();
                query.addWhereEqualTo("opponent", teams.get(i));
                query.addWhereLessThan("start_time", new BmobDate(new Date()));
                queries.add(query);
            }
        }

        BmobQuery<Tournament> totalQuery = new BmobQuery<Tournament>();
        totalQuery.order("-start_time");
        totalQuery.setLimit(1);
        totalQuery.include("home_court,opponent");
        totalQuery.or(queries);
        totalQuery.findObjects(mContext, findListener);
    }
    /*
    * 查询指定用户的参加的所有比赛的信息
    * */
    public void getUserCompetition(User user,FindListener<PlayerScore> findListener){
    	BmobQuery<PlayerScore> query = new BmobQuery<PlayerScore>();
    	query.addWhereEqualTo("player", user);
    	query.addWhereLessThan("createdAt", new BmobDate(new Date()));
    	query.include("competition,competition.home_court,competition.opponent,league");
        query.order("-createdAt");
        query.setLimit(1000);
    	query.findObjects(mContext, findListener);
    }


    public void getLastCompetition(List<Team> teams,FindListener findListener,int limite){
        List<BmobQuery<Tournament>> queries = new ArrayList<BmobQuery<Tournament>>();
        if(teams!=null&&teams.size()>0){
            for(int i=0;i<teams.size();i++){
                BmobQuery<Tournament> query = new BmobQuery<Tournament>();
                query.addWhereEqualTo("home_court", teams.get(i));
                query.addWhereLessThan("start_time", new BmobDate(new Date()));
                queries.add(query);
            }
            for(int i=0;i<teams.size();i++){
                BmobQuery<Tournament> query = new BmobQuery<Tournament>();
                query.addWhereEqualTo("opponent", teams.get(i));
                query.addWhereLessThan("start_time", new BmobDate(new Date()));                
                queries.add(query);
            }
        }
        BmobQuery<Tournament> totalQuery = new BmobQuery<Tournament>();
        totalQuery.order("-start_time");
        totalQuery.setLimit(limite);
        totalQuery.include("home_court,opponent,opponent.captain,home_court.captain,league");
        totalQuery.or(queries);
        totalQuery.findObjects(mContext, findListener);
    }
    
    
    /**
     * 
     * @Title:        getNextCompetition 
     * @Description:  用户球队的下一场,当为下一场时，limite为1，当为未来是，limite为其他数
     * @param:        @param findListener    
     * @return:       void    
     * @throws 
     * @author        kingofglory
     * @Date          2014-9-3 上午9:22:30
     */
    public void getNextCompetition(List<Team> teams,FindListener<Tournament> findListener,int limite){
        List<BmobQuery<Tournament>> queries = new ArrayList<BmobQuery<Tournament>>();
        if(teams!=null&&teams.size()>0){
            for(int i=0;i<teams.size();i++){
                BmobQuery<Tournament> query = new BmobQuery<Tournament>();
                query.addWhereEqualTo("home_court", teams.get(i));
                query.addWhereGreaterThan("start_time", new BmobDate(new Date()));
                queries.add(query);
            }
            for(int i=0;i<teams.size();i++){
                BmobQuery<Tournament> query = new BmobQuery<Tournament>();
                query.addWhereEqualTo("opponent", teams.get(i));
                query.addWhereGreaterThan("start_time", new BmobDate(new Date()));
                queries.add(query);
            }
            
        }
        
        BmobQuery<Tournament> totalQuery = new BmobQuery<Tournament>();
        totalQuery.order("start_time");
        totalQuery.setLimit(limite);
        totalQuery.include("home_court,opponent,league,group");
        totalQuery.or(queries);
        totalQuery.findObjects(mContext, findListener);
    }
    
    /**
     * 联赛赛程
     */
    public void getLeagueSaiCheng(League league,int limite,FindListener<Tournament> listener){
    	if(league == null){
    		return;
    	}
    	BmobQuery<Tournament> query = new BmobQuery<Tournament>();
    	query.addWhereEqualTo("league", league);
    	query.addWhereGreaterThan("start_time", new BmobDate(new Date()));
    	query.order("start_time");
    	query.include("home_court,opponent,league,group");
    	query.setLimit(limite);
    	query.findObjects(mContext, listener);
    	
    }
    
    /**
     * 联赛结果
     */
    public void getLeagueResult(League league,int limite,FindListener<Tournament> listener){
    	if(league == null){
    		return;
    	}
    	BmobQuery<Tournament> query = new BmobQuery<Tournament>();
    	query.addWhereEqualTo("league", league);
    	query.addWhereLessThan("start_time", new BmobDate(new Date()));
    	query.order("-start_time");
    	query.include("home_court,opponent,league,group");
    	query.setLimit(limite);
    	query.findObjects(mContext, listener);
    	
    }

    /**
     * 获取指定的联赛信息
     */
    public void getLeague(String objectId,FindListener<League>listener){
        BmobQuery<League> query = new BmobQuery<League>();
        query.addWhereEqualTo("objectId",objectId);
        query.findObjects(mContext,listener);
    }


}
