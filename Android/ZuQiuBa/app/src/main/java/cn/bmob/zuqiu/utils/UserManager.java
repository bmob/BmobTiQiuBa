package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.text.TextUtils;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.datatype.BmobRelation;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

/**
 * @author venus
 *
 */
public class UserManager {
	private Context mContext;
	private User mUser;
	public UserManager(Context mContext) {
		super();
		this.mContext = mContext;
		this.mUser = getUser();
	}
	
	private User getUser(){
		return BmobUser.getCurrentUser(mContext, User.class);
	}

    public String getCurrentUserName(){
        return getUser()!=null ? getUser().getUsername():"";
    }

	public void getFriend(FindListener<User> listener){
		BmobQuery<User> query = new BmobQuery<User>();
		query.addWhereRelatedTo("friends", new BmobPointer(mUser));
		query.findObjects(mContext, listener);
	}
	
	public void exitTeam(User user,Team team,UpdateListener listenter){
		if(user==null||team==null){
			return;
		}
		BmobRelation relation = new BmobRelation();
		relation.remove(user);
		team.setFootballer(relation);
		team.update(mContext, listenter);
	}
	
	/**
	 * 添加或者删除好友
	 * @param msg
	 * @param isAdd：true为添加，false为删除
	 */
	public void addFriend(PushMessage msg,final boolean isAdd){
		if(msg == null){
			return;
		}
		
		if(!TextUtils.isEmpty(msg.getTargetId())){
			BmobRelation relation = new BmobRelation();
			User user = new User();
			user.setObjectId(msg.getTargetId());
			if(isAdd){
				relation.add(user);
			}else{
				relation.remove(user);
			}
			mUser.setFriends(relation);
			mUser.update(mContext, new UpdateListener() {
				
				@Override
				public void onSuccess() {
					// TODO Auto-generated method stub
					if(isAdd){
						ToastUtil.showToast(mContext, "发送添加好友请求成功");
					}else{
						ToastUtil.showToast(mContext, "发送删除好友请求成功");
					}
				}
				
				@Override
				public void onFailure(int arg0, String arg1) {
					// TODO Auto-generated method stub
					if(isAdd){
						ToastUtil.showToast(mContext, "发送好友请求失败。");
					}else{
						ToastUtil.showToast(mContext, "发送删除好友请求失败");
					}
				}
			});
		}
	}
	
	
	/**
	 * 添加或者删除好友
	 * @param objectId
	 * @param isAdd：true为添加，false为删除
	 */
	public void addFriend(String objectId,final boolean isAdd,UpdateListener listener){
		if(!TextUtils.isEmpty(objectId)){
			BmobRelation relation = new BmobRelation();
			User user = new User();
			user.setObjectId(objectId);
			if(isAdd){
				relation.add(user);
			}else{
				relation.remove(user);
			}
			mUser.setFriends(relation);
			mUser.update(mContext, listener);
		}
	}

    /**
     * 更新用户的百度推送id
     * @param pushUserId
     * @param pushChannelId
     */
    public void updateUserPushId(String pushUserId, String pushChannelId){
        if(getUser() == null){
            return;
        }
        LogUtil.d("zuqiuba", "更新用户百度推送id");
        User user = getUser();
//        user.setObjectId(getUser().getObjectId());
        user.setPushUserId(pushUserId);
        user.setPushChannelId(pushChannelId);
        user.setDeviceType("android");
        user.update(mContext);
    }
    
}
