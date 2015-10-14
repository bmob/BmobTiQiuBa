package cn.bmob.zuqiu.share;

import android.content.Context;
import cn.bmob.zuqiu.R;

public class ShareHelper {
	
	public static void share(Context context,ShareData data){
		data.setTitle(data.getTitle());
		data.setText(data.getText());
		data.setImageUrl(data.getImageUrl());
		data.setUrl(data.getUrl());
		ShareDialog shareDialog = new ShareDialog(context, R.style.MyDialog);
		shareDialog.setShareData(data);
		shareDialog.show();
	}
	
	/**
	 * 个人总体数据,要把球员的objectId传过来
	 * @param userObjectId
	 * @return
	 */
	public static String getPersonalTotalData(String userObjectId){
		return "http://tq.codenow.cn/share/PersonTotalData?user="+userObjectId;
	}

	/**
	 * 球队阵容,要把球队的teamId传过来
	 * @param teamObjectId
	 * @return
	 */
	public static String getLineupUrl(String teamObjectId){
		return "http://tq.codenow.cn/share/GameLineup?team="+teamObjectId;
	}
	
	/**
	 * 比赛报告，要把比赛的objectId以及球队的obejectId传过来
	 * @param compeObjectId
	 * @param teamObjectId
	 * @return
	 */
	public static String getCompetitionReport(String compeObjectId,String teamObjectId){
		return "http://tq.codenow.cn/share/GameData?game="+compeObjectId+"+&team="+teamObjectId;
	}
	
	/**
	 * 球员比赛数据,要把球员的objectId以及比赛的obejectId传过来
	 * @param memberObjectId
	 * @param compeObjectId
	 * @return
	 */
	public static String getCommentData(String memberObjectId,String compeObjectId){
		return "http://tq.codenow.cn/share/PlayerComment?player="+memberObjectId+"&game="+compeObjectId;
	}
	
	/**
	 * 球员比赛详细数据,要把球员的objectId以及比赛的obejectId传过来
	 * @param memberObjectId
	 * @param compeObjectId
	 * @return
	 */
	public static String getGameData(String memberObjectId,String compeObjectId){
		return "http://tq.codenow.cn/share/PersonGameData?player="+memberObjectId+"&game="+compeObjectId;
	}
	
	/**
	 * 联赛数据,要把联赛对应的obejectId传过来
	 * @param leagueObjectId
	 * @return
	 */
	public static String getLeagueData(String leagueObjectId){
		return "http://tq.codenow.cn/share/LeagueData?league="+leagueObjectId;
	}
	
	/**
	 * 联赛射手榜,要把联赛对应的obejectId传过来
	 * @param leagueObjectId
	 * @return
	 */
	public static String getLeagueShoter(String leagueObjectId){
		return "http://tq.codenow.cn/share/playerScoreData?league="+leagueObjectId;
	}
	
	public static final String downloadUrl = "http://tq.codenow.cn/share/Download";

	public static final String iconUrl = "https://mmbiz.qlogo.cn/mmbiz/38vScRd1ASAaN0GfnW6e3AuC7nia0fRQkqXVCAX3XNCyJ4BHA00IEc7b7NTQPT1jKqj8HiapRdykn7AicGYrVbFibA/0";
}
