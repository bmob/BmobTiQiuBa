package cn.bmob.zuqiu.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiuj.bean.PlayerScore;
import cn.bmob.zuqiuj.bean.Tournament;

public class PersonalRecordAdapter extends BaseAdapter{

	private Context mContext;
	private List<PlayerScore> data;
    private List<Integer> yearData = new ArrayList<Integer>();
	
	public PersonalRecordAdapter(Context mContext, List<PlayerScore> data) {
		super();
		this.mContext = mContext;
		this.data = data;
        //按时间的降序排列
        Collections.sort(this.data, new Comparator<PlayerScore>() {
            @Override
            public int compare(PlayerScore lhs, PlayerScore rhs) {
                return compareCurrentTime(lhs.getCompetition().getEvent_date(), rhs.getCompetition().getEvent_date());
            }
        });

        for(PlayerScore t:this.data){
            yearData.add(TimeUtils.getCurrentYearNumber(t.getCompetition().getStart_time()));
        }

    }

    /**
     * 比较时间
     * @return
     */
    public static int compareCurrentTime(BmobDate date1, BmobDate date2){
        try {
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date d1 = df.parse(date1.getDate());
            Date d2 = df.parse(date2.getDate());
//            return ((int)d1.getTime()) - ((int)d2.getTime());
            // 对日期字段进行升序，如果欲降序可采用after方法
            if (d1.before(d2)) {
                return 1;
            }
            return -1;
        } catch (ParseException e) {
            return 0;
        }
    }

	public void setData(List<PlayerScore> data) {
		this.data = data;
        //按时间的降序排列
        Collections.sort(this.data, new Comparator<PlayerScore>() {
            @Override
            public int compare(PlayerScore lhs, PlayerScore rhs) {
            return compareCurrentTime(lhs.getCompetition().getEvent_date(), rhs.getCompetition().getEvent_date());
            }
        });

        for(PlayerScore t:this.data){
            yearData.add(TimeUtils.getCurrentYearNumber(t.getCompetition().getStart_time()));
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
		if(convertView == null){
			viewHolder = new ViewHolder();
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_personal_record, null);
			viewHolder.nearDate = (TextView)convertView.findViewById(R.id.near_com_date);
			viewHolder.nearTime = (TextView)convertView.findViewById(R.id.near_com_time);
			viewHolder.tournamentName = (TextView)convertView.findViewById(R.id.near_com_name);
			viewHolder.tournamentTeams = (TextView)convertView.findViewById(R.id.near_com_teams);
			viewHolder.vsPoints = (TextView)convertView.findViewById(R.id.vs_points);
			viewHolder.opponentTeam = (TextView)convertView.findViewById(R.id.opponent_team);
			viewHolder.lastInGoals = (TextView)convertView.findViewById(R.id.last_in_goals);
			viewHolder.lastAssistGoals = (TextView)convertView.findViewById(R.id.last_assist_goals);
			viewHolder.rz = (ImageView)convertView.findViewById(R.id.rz);
            viewHolder.yearTime = (TextView)convertView.findViewById(R.id.time_year);
			convertView.setTag(viewHolder);
		}else{
			viewHolder = (ViewHolder) convertView.getTag();
		}

        //
		Tournament mTournament = data.get(position).getCompetition();

		viewHolder.nearDate.setText(TimeUtils.getCompetitionDate(mTournament.getEvent_date()));
		viewHolder.nearTime.setText(TimeUtils.getCompetitionTime(mTournament.getStart_time()));
        if(mTournament.getLeague()!=null){
            
        }else{
            viewHolder.tournamentName.setText("友谊赛");
        }
//		viewHolder.tournamentName.setText(mTournament.getName());
		viewHolder.tournamentTeams.setText(mTournament.getHome_court().getName());
		viewHolder.opponentTeam.setText(mTournament.getOpponent().getName());

        int section = getSectionForPosition(position);
        if(position == getPositionForSection(section)){
            viewHolder.yearTime.setVisibility(View.VISIBLE);
            viewHolder.yearTime.setText(yearData.get(position)+"年");
        }else{
            viewHolder.yearTime.setVisibility(View.GONE);
        }
		
		if(mTournament.isVerify()){
//			if(mTournament.getScore()==null){
//				viewHolder.vsPoints.setText("0-0");
//			}else{
            String sh1 = TextUtils.isEmpty(mTournament.getScore_h())?"0":mTournament.getScore_h();
            String sh2 = TextUtils.isEmpty(mTournament.getScore_h2())?"0":mTournament.getScore_h2();
		    viewHolder.vsPoints.setText(sh1+"-"+sh2);
//			}
			viewHolder.rz.setVisibility(View.VISIBLE);
		}else{
			if(TextUtils.isEmpty(mTournament.getScore_h())&&TextUtils.isEmpty(mTournament.getScore_o())){
				viewHolder.vsPoints.setText("0-0");
	    	}else{
	    		for(int i=0;i<MyApplication.getInstance().getTeams().size();i++){
//                    if(mTournament.getHome_court().getObjectId().equals(MyApplication.getInstance().getTeams().get(i).getObjectId())){
	    			if(MyApplication.getInstance().getTeams().get(i).getObjectId().equals(mTournament.getHome_court().getObjectId())){
	    				String score_h = mTournament.getScore_h();
						if(TextUtils.isEmpty(mTournament.getScore_h())){
							score_h = "0";
						}
						String score_h2 = mTournament.getScore_h2();
						if(TextUtils.isEmpty(mTournament.getScore_h2())){
							score_h2 = "0";
						}
	    				viewHolder.vsPoints.setText(score_h+"-"+score_h2);
	    				break;
	    			}else{
                        String so1 = TextUtils.isEmpty(mTournament.getScore_o())?"0":mTournament.getScore_o();
                        String so2 = TextUtils.isEmpty(mTournament.getScore_o2())?"0":mTournament.getScore_o2();
	    				viewHolder.vsPoints.setText(so2+"-"+so1);
	    			}
	    		}
	    	}
			viewHolder.rz.setVisibility(View.GONE);
		}

        //显示助攻和进球
        viewHolder.lastInGoals.setText(data.get(position).getGoals() == null ? "0" : data.get(position).getGoals()+"");
        viewHolder.lastAssistGoals.setText(data.get(position).getAssists() == null ? "0" : data.get(position).getAssists()+ "");

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
	
	private class ViewHolder{
		TextView nearDate;
		TextView nearTime;
		TextView tournamentName;
		TextView tournamentTeams;
		TextView vsPoints;
		TextView opponentTeam;
		TextView lastInGoals;
		TextView lastAssistGoals;
		ImageView rz;
        TextView yearTime;
	}
	
}
