package cn.bmob.zuqiu.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PlayerScoreManager;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiu.utils.TournamentHelper;
import cn.bmob.zuqiu.view.views.MyGridView;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.Lineup;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;

public class TeamRecordAdapter extends BaseAdapter {

	private Context mContext;
	private List<Tournament> data;
    private List<Integer> yearData = new ArrayList<Integer>();

	public TeamRecordAdapter(Context mContext, List<Tournament> data) {
		super();
		this.mContext = mContext;
		this.data = data;
        for(Tournament t:data){
            yearData.add(TimeUtils.getCurrentYearNumber(t.getStart_time()));
        }
	}

	public void setData(List<Tournament> data) {
		this.data = data;
        for(Tournament t:data){
            yearData.add(TimeUtils.getCurrentYearNumber(t.getStart_time()));
        }
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return data.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return data.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		final ViewHolder viewHolder;
		if (convertView == null) {
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_team_record, null);
			viewHolder.nearDate = (TextView) convertView.findViewById(R.id.near_com_date);
			viewHolder.nearTime = (TextView) convertView.findViewById(R.id.near_com_time);
			viewHolder.nature = (TextView)convertView.findViewById(R.id.tournament_nature);
			viewHolder.tournamentName = (TextView) convertView.findViewById(R.id.near_com_name);
			viewHolder.tournamentTeams = (TextView) convertView.findViewById(R.id.near_com_teams);
			viewHolder.vsPoints = (TextView) convertView.findViewById(R.id.vs_points);
			viewHolder.opponentTeam = (TextView) convertView.findViewById(R.id.opponent_team);
			viewHolder.rz = (ImageView) convertView.findViewById(R.id.rz);
//			viewHolder.lineup = (MyGridView) convertView.findViewById(R.id.team_lineup);
            viewHolder.yearTime = (TextView)convertView.findViewById(R.id.time_year);
			convertView.setTag(viewHolder);
		} else {
			viewHolder = (ViewHolder) convertView.getTag();
		}

		Tournament mTournament = data.get(position);
		LogUtil.i("points",mTournament.getScore_h()+" x "+mTournament.getScore_h2()
				+" x "+mTournament.getScore_o()+" x "+mTournament.getScore_o2());
		viewHolder.nearDate.setText(TimeUtils.getCompetitionDate(mTournament
				.getEvent_date()));
		viewHolder.nearTime.setText(TimeUtils.getCompetitionTime(mTournament
				.getStart_time()));
		if(mTournament.getLeague()!=null){
			viewHolder.tournamentName.setText(mTournament.getLeague().getName());
			viewHolder.nature.setText(TournamentHelper.getNature(mTournament.getNature()));
		}else{
			viewHolder.tournamentName.setText(mTournament.getName());
			viewHolder.nature.setText("友谊赛");
		}

        int section = getSectionForPosition(position);
        if(position == getPositionForSection(section)){
            viewHolder.yearTime.setVisibility(View.VISIBLE);
            viewHolder.yearTime.setText(yearData.get(position)+"年");
        }else{
            viewHolder.yearTime.setVisibility(View.GONE);
        }
		
		viewHolder.tournamentTeams.setText(mTournament.getHome_court()
				.getName());
		viewHolder.opponentTeam.setText(mTournament.getOpponent().getName());

		if (mTournament.isVerify()) {
            String sh1 = TextUtils.isEmpty(mTournament.getScore_h())?"0":mTournament.getScore_h();
            String sh2 = TextUtils.isEmpty(mTournament.getScore_h2())?"0":mTournament.getScore_h2();
		    viewHolder.vsPoints.setText(sh1+"-"+sh2);
			viewHolder.rz.setVisibility(View.VISIBLE);
		} else {
			if (TextUtils.isEmpty(mTournament.getScore_h())
					&& TextUtils.isEmpty(mTournament.getScore_o())
					&&TextUtils.isEmpty(mTournament.getScore_h2())
					&&TextUtils.isEmpty(mTournament.getScore_o2())) {
				viewHolder.vsPoints.setText("0-0");
			} else {
				for (int i = 0; i < MyApplication.getInstance().getTeams()
						.size(); i++) {
					if (mTournament.getHome_court().getObjectId().equals(MyApplication
							.getInstance().getTeams().get(i).getObjectId())) {
						String score_h = mTournament.getScore_h();
						if(TextUtils.isEmpty(mTournament.getScore_h())){
							score_h = "0";
						}
						String score_h2 = mTournament.getScore_h2();
						if(TextUtils.isEmpty(mTournament.getScore_h2())){
							score_h2 = "0";
						}
						viewHolder.vsPoints.setText(score_h
								+ "-" + score_h2);
						break;
					} else {
                        String so1 = TextUtils.isEmpty(mTournament.getScore_o())?"0":mTournament.getScore_o();
                        String so2 = TextUtils.isEmpty(mTournament.getScore_o2())?"0":mTournament.getScore_o2();
						viewHolder.vsPoints.setText(so2+ "-" + so1);
					}
				}
			}
			viewHolder.rz.setVisibility(View.GONE);
		}
		
//		for(int i=0;i<MyApplication.getInstance().getTeams().size();i++){
//			if (mTournament.getHome_court().getObjectId().equals(MyApplication
//					.getInstance().getTeams().get(i).getObjectId())){
//				LogUtil.i("name","NAME:"+mTournament.getHome_court().getName());
//				getLineup(mTournament.getHome_court(),viewHolder.lineup);
//				break;
//			}else{
//				getLineup(mTournament.getOpponent(),viewHolder.lineup);
//				break;
//			}
//		}
		
//		switch (MyApplication.getInstance().getTeams().size()) {
//		case 1:
//			if (MyApplication.getInstance().getTeams().get(0).getObjectId().equals(mTournament.getHome_court().getObjectId())){
//				getPlayerScores(mTournament, mTournament.getHome_court(), viewHolder.lineup);
//			}else{
//				getPlayerScores(mTournament, mTournament.getOpponent(), viewHolder.lineup);
//			}
//			
//			break;
//		case 2:
//            
//			if (MyApplication.getInstance().getTeams().get(0).getObjectId().equals(mTournament.getHome_court().getObjectId())){
//				getPlayerScores(mTournament, mTournament.getHome_court(), viewHolder.lineup);
//			}else if (MyApplication.getInstance().getTeams().get(1).getObjectId().equals(mTournament.getHome_court().getObjectId())){
//				getPlayerScores(mTournament, mTournament.getHome_court(), viewHolder.lineup);
//			}else{
//				getPlayerScores(mTournament, mTournament.getOpponent(), viewHolder.lineup);
//			}
//			break;
//		default:
//			break;
//		}
		

		return convertView;
	}

    /**
     * 根据ListView的当前位置获取分类的首字母的Char ascii值
     */
    public int getSectionForPosition(int position) {
        return yearData.get(position);
    }

    /**
     * 根据分类的首字母的Char ascii值获取其第一次出现该首字母的位置
     */
    public int getPositionForSection(int section) {
        for (int i = 0; i < getCount(); i++) {
            int sortStr = yearData.get(i);
            int firstChar = sortStr;
            if (firstChar == section) {
                return i;
            }
        }

        return -1;
    }
	
	
	private void getPlayerScores(Tournament mTournament,Team team,final MyGridView gv){
		PlayerScoreManager.getTeamPlayerScoreInTournament(mContext, team, mTournament, "-createdAt", new FindListener<PlayerScore>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onSuccess(List<PlayerScore> list) {
				// TODO Auto-generated method stub
				ArrayList<User> scorer = new ArrayList<User>();
				for(PlayerScore score:list){
					scorer.add(score.getPlayer());
//					LogUtil.i("scorer", score.getPlayer().getNickname()+score.getCreatedAt());
				}
				gv.setAdapter(new LineupAdapter(mContext, scorer));
			}
		});
	}

	private class ViewHolder {
		TextView nearDate;
		TextView nearTime;
		TextView nature;
		TextView tournamentName;
		TextView tournamentTeams;
		TextView vsPoints;
		TextView opponentTeam;
		ImageView rz;
		MyGridView lineup;
        TextView yearTime;
	}

	private void getLineup(Team firstTeam,final MyGridView gv){
		final List<User> lineupList = new ArrayList<User>();
		BmobQuery<Lineup> query = new BmobQuery<Lineup>();
		query.addWhereEqualTo("team", firstTeam);
		query.include("team,goalkeeper");
		query.order("-updateAt");
		query.findObjects(mContext, new FindListener<Lineup>() {

			@Override
			public void onError(int arg0, String arg1) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onSuccess(List<Lineup> arg0) {
				// TODO Auto-generated method stub
				
				if(arg0!=null&&arg0.size()>0){
					LogUtil.i("MainActivity","FIND:"+arg0.get(0).getObjectId());
					User user = arg0.get(0).getGoalkeeper();
					if(user!=null){
						lineupList.add(user);
					}
					
//					getMemberByType(arg0.get(0),"back");
//					getMemberByType(arg0.get(0), "striker");
//					getMemberByType(arg0.get(0), "forward");
					getMemberByType(arg0.get(0), lineupList,gv,"back");
					getMemberByType(arg0.get(0), lineupList,gv,"striker");
					getMemberByType(arg0.get(0), lineupList,gv,"forward");
				}
			}
		});
	}
	
	/**
	 * 获取后卫人员
	 */
	private void getMemberByType(Lineup lineup,final List<User> list,final MyGridView gv,String memberType){
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
				if(arg0!=null&&arg0.size()>0){
					list.addAll(arg0);
				}
				if(list!=null){
					gv.setAdapter(new LineupAdapter(mContext, list));
				}
			}
		});
	}
	
//	/**
//	 * 获取后卫人员
//	 */
//	private void getMemberByType(Lineup lineup,final List<User> list,final MyGridView gv){
//		if(lineup==null)
//			return;
//		List<BmobQuery<User>> querys = new ArrayList<BmobQuery<User>>();
//		
//		BmobQuery<User> queryback = new BmobQuery<User>();
//		queryback.addWhereRelatedTo("back", new BmobPointer(lineup));
//		querys.add(queryback);
//		LogUtil.i("back","lineup id:"+lineup.getObjectId());
//		BmobQuery<User> querystriker = new BmobQuery<User>();
//		querystriker.addWhereRelatedTo("striker", new BmobPointer(lineup));
//		querys.add(querystriker);
//		
//		BmobQuery<User> forward = new BmobQuery<User>();
//		forward.addWhereRelatedTo("forward", new BmobPointer(lineup));
//		querys.add(forward);
//		
//		BmobQuery<User> mainQuery = new BmobQuery<User>();
//		mainQuery.or(querys);
//		mainQuery.findObjects(mContext, new FindListener<User>() {
//
//			@Override
//			public void onError(int arg0, String arg1) {
//				// TODO Auto-generated method stub
//				
//			}
//
//			@Override
//			public void onSuccess(List<User> arg0) {
//				// TODO Auto-generated method stub
//				if(arg0!=null&&arg0.size()>0){
//					list.addAll(arg0);
//					ToastUtil.showToast(mContext, list.size()+"");
//					
//					gv.setAdapter(new LineupAdapter(mContext, list));
//				}
//			}
//		});
//	}
	
}
