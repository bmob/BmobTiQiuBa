//package cn.bmob.zuqiu.utils;
//
//
//import java.util.ArrayList;
//import java.util.List;
//
//import org.json.JSONObject;
//
//import android.content.Context;
//import cn.bmob.v3.BmobInstallation;
//import cn.bmob.v3.BmobPushManager;
//import cn.bmob.v3.BmobQuery;
//
///**
// *推送助手类
// * @author venus
// *
// */
//public class PushHelper {
//	private Context context;
//	private BmobPushManager manager;
//	public PushHelper(Context context) {
//		super();
//		this.context = context;
//		initManager();
//	}
//	
//	private BmobPushManager initManager(){
//		if(manager == null){
//			manager = new BmobPushManager(context);
//		}
//		return manager;
//	}
//	
//	/**
//	 * 根据相关条件推送
//	 * @param queryKey
//	 * @param queryValue
//	 * @param pushContent
//	 */
//	public void pushToAndroid(String queryKey,String queryValue,String pushContent){
//		BmobQuery<BmobInstallation> query = BmobInstallation.getQuery();
//		query.addWhereEqualTo(queryKey, queryValue);
//		manager.setQuery(query);
//		manager.pushMessage(pushContent);
//	}
//	
//	public void pushToAndroidByJson(String queryKey,String queryValue,JSONObject json){
//		BmobQuery<BmobInstallation> query = BmobInstallation.getQuery();
//		query.addWhereEqualTo(queryKey, queryValue);
//		query.order("-updatedAt");
//		manager.setQuery(query);
//		manager.pushMessage(json);
//	}
//	
//	public void pushToChannelByJson(String channel,JSONObject json){
//		BmobQuery<BmobInstallation> query = BmobInstallation.getQuery();
//		
//		List<String> channels = new ArrayList<String>();
//		channels.add(channel);
//		
//		query.addWhereContainedIn("channels", channels);
//		manager.setQuery(query);
//		manager.pushMessage(json);
//	}
//	
//	/**
//	 * 根据installid推送
//	 * @param queryValue
//	 * @param pushContent
//	 */
//	public void pushToAndroidById(String queryValue,String pushContent){
//		pushToAndroid("uid", queryValue, pushContent);
//	}
//	
//	public void pushToAndroidByJson(String queryValue,JSONObject json){
//		pushToAndroidByJson("uid", queryValue, json);
//	}
//}
