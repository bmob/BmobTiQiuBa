package cn.bmob.zuqiu.utils;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import cn.bmob.v3.AsyncCustomEndpoints;
import cn.bmob.v3.listener.CloudCodeListener;

public class CloudCode {
	
	/**
	 * 云端代码方法调用
	 * @param context
	 * @param params
	 * @param methodName
	 * @param listener
	 */
	public static void cloudRequest(Context context,JSONObject params,String methodName,CloudCodeListener listener){
		AsyncCustomEndpoints request = new AsyncCustomEndpoints();
		request.callEndpoint(context, methodName, params, listener);
	}
	
	/**
	 * 1)赛事认证
	 * @param context
	 * @param tournamentObjectId
	 * @param listener
	 */
	public static void authTournament(Context context,String tournamentObjectId,CloudCodeListener listener){
		JSONObject params = new JSONObject();
		try {
			params.put("objectId", tournamentObjectId);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		cloudRequest(context, params, "authTournament", listener);
	}
	
	/**
	 * 5)统计用户参赛资料信息（参数次数、进球、助攻、得分）
	 * 统计球员在各项比赛的总体数据包括（参赛次数、进球数、助攻数），
	 * 主要是查询PlayerScore表，
	 * 然后把数据汇总到_User表的games、goals、assists三个字段中。
	 * 
	 * 客户端触发条件：
		从主功能页点击下一场比赛进入比赛界面，
		用户修改自己的进球和助攻数（或者队长可以修改其他的进球和助攻数），
		并将修改更新到数据库后，触发调用该函数。
		注：用户界面只显示这几项数据不会调用该函数。
	 * @param context
	 * @param userObjectId
	 * @param listener
	 */
	public static void userGoalAssist(Context context,String userObjectId,CloudCodeListener listener){
		JSONObject params = new JSONObject();
		try {
			params.put("objectId", userObjectId);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		cloudRequest(context, params, "userGoalAssist", listener);
	}
	
	/**
	 * 2）获取某个球员所参与的比赛的评分的平均数，
	 *    主要是查询Comment表，获取各球员的平均分，
	 *    再记录到_User表的score字段
	 *    
	 *    从主功能页点击下一场比赛进入比赛界面并且点击其他用户的评分平均数显示位置，
	 *    用户发布或修改对别人评分和评论，并将修改更新到数据库后，触发调用该函数。
	 *    注：用户界面只显示这该项数据不会调用该函数。
	 * @param context
	 * @param userObjectId
	 * @param listener
	 */
	public static void commentScore(Context context,String userObjectId,CloudCodeListener listener){
		JSONObject params = new JSONObject();
		try {
			params.put("objectId", userObjectId);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		cloudRequest(context, params, "commentScore", listener);
	}
	
	/**
	 * 4)统计球队在各项比赛中总体数据，主要是查询TeamScore表，
	 * 然后把数据统计完后更新到Team表中。
	 * 
	 * 从主功能页点击下一场比赛进入比赛界面，
	 * 队长修改比赛的比分，并将修改更新到数据库后，
	 * 并调用完赛事认证云代码后，触发调用该函数。
	 * 注：球队界面只显示这几项数据不会调用该函数。
	 * @param context
	 * @param teamObjectId
	 * @param listener
	 */
	public static void teamData(Context context,String teamObjectId,CloudCodeListener listener){
		JSONObject params = new JSONObject();
		try {
			params.put("objectId", teamObjectId);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		cloudRequest(context, params, "teamData", listener);
	}
	
}
