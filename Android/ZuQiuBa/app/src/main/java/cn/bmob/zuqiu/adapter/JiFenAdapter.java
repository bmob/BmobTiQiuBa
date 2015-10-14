package cn.bmob.zuqiu.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.List;

import cn.bmob.zuqiu.R;
import cn.bmob.zuqiuj.bean.LeagueScoreStat;

public class JiFenAdapter extends BaseAdapter {
    private Context mContext;
    private List<LeagueScoreStat> mLeagueScoreStats;

    public JiFenAdapter(Context context, List<LeagueScoreStat> lss){
        this.mContext = context;
        this.mLeagueScoreStats = lss;
    }

    @Override
    public int getCount() {
        return mLeagueScoreStats.size();
    }

    @Override
    public Object getItem(int position) {
        return mLeagueScoreStats.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(mContext).inflate(R.layout.item_jifen, null);

            viewHolder.titleLayout = (LinearLayout) convertView.findViewById(R.id.ll_tableTitle);
            viewHolder.groupName = (TextView) convertView.findViewById(R.id.tv_groupName);
            viewHolder.paiming = (TextView)convertView.findViewById(R.id.tv_paiming);
            viewHolder.teamname = (TextView)convertView.findViewById(R.id.tv_qiudui);
            viewHolder.shen = (TextView)convertView.findViewById(R.id.tv_shen);
            viewHolder.ping = (TextView)convertView.findViewById(R.id.tv_ping);
            viewHolder.fu = (TextView)convertView.findViewById(R.id.tv_fu);
            viewHolder.jinqiu = (TextView)convertView.findViewById(R.id.tv_jinqiu);
            viewHolder.shiqiu = (TextView)convertView.findViewById(R.id.tv_shiqiu);
            viewHolder.jinshengqiu = (TextView)convertView.findViewById(R.id.tv_jingshengqiu);
            viewHolder.jifen = (TextView)convertView.findViewById(R.id.tv_jifen);
            convertView.setTag(viewHolder);
        }else{
            viewHolder = (ViewHolder) convertView.getTag();
        }

        if(position%2==0){
            convertView.setBackgroundResource(R.drawable.bg_list_item_hui);
        }else{
            convertView.setBackgroundResource(R.drawable.back);
        }

        LeagueScoreStat lss = mLeagueScoreStats.get(position);
        String groupName = lss.getGroupName();
        if(position==0){
            viewHolder.groupName.setText((groupName==null ?"#":groupName)+"组");
            viewHolder.groupName.setVisibility(View.VISIBLE);
            viewHolder.titleLayout.setVisibility(View.VISIBLE);
        }else{
            if(position-1>0){
                LeagueScoreStat next = mLeagueScoreStats.get(position-1);
                String nextGroup = next.getGroupName();
                if(groupName.equals(nextGroup)){
                    viewHolder.groupName.setVisibility(View.GONE);
                    viewHolder.titleLayout.setVisibility(View.GONE);
                }else{
                    viewHolder.groupName.setText(groupName+"组");
                    viewHolder.groupName.setVisibility(View.VISIBLE);
                    viewHolder.titleLayout.setVisibility(View.VISIBLE);
                }
            }else{
                String newGroup =mLeagueScoreStats.get(1).getGroupName();
                if(groupName.equals(newGroup)){
                    viewHolder.groupName.setVisibility(View.GONE);
                    viewHolder.titleLayout.setVisibility(View.GONE);
                }else{
                    viewHolder.groupName.setText(groupName+"组");
                    viewHolder.groupName.setVisibility(View.VISIBLE);
                    viewHolder.titleLayout.setVisibility(View.VISIBLE);
                }
            }
        }
        viewHolder.paiming.setText(String.valueOf(lss.getIndex()));
        viewHolder.teamname.setText(lss.getTeam().getName());
        viewHolder.shen.setText(lss.getWin()+"");
        viewHolder.ping.setText(lss.getDraw()+"");
        viewHolder.fu.setText(lss.getLoss()+"");
        viewHolder.jinqiu.setText(lss.getGoals()+"");
        viewHolder.shiqiu.setText(lss.getGoalsAgainst()+"");
        viewHolder.jinshengqiu.setText(lss.getGoalDifference()+"");
        viewHolder.jifen.setText(lss.getPoints()+"");

        return convertView;
    }

    private class ViewHolder{
        LinearLayout titleLayout;
        TextView groupName;
        TextView paiming;
        TextView teamname;
        TextView shen;
        TextView ping;
        TextView fu;
        TextView jinqiu;
        TextView shiqiu;
        TextView jinshengqiu;
        TextView jifen;
    }
}
