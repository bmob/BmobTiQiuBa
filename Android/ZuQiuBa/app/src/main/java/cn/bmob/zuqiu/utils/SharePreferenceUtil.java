package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class SharePreferenceUtil {
    private SharedPreferences mSharedPreferences;
    private static SharedPreferences.Editor editor;

    public SharePreferenceUtil(Context context) {
        mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        editor = mSharedPreferences.edit();
    }

    public boolean isFirstPersonalCenter(){
        return mSharedPreferences.getBoolean("isFirstPersonalCenter",true);
    }

    public void setFirstPersonalCenter(boolean b){
        editor.putBoolean("isFirstPersonalCenter", b).commit();
    }

    public boolean isFirstCompetitionInfo(){
        return mSharedPreferences.getBoolean("isFirstCompetitionInfo", true);
    }

    public void setFirstCompetitionInfo(boolean b){
        editor.putBoolean("isFirstCompetitionInfo", b).commit();
    }

    /**
     * 记录检查更新的时间
     * @param time
     */
    public void setLastUpdateTime(long time){
        editor.putLong("lastUpdateTime", time).commit();
    }

    /**
     * 获取最后一次检查更新d时间
     * @return
     */
    public long getLastUpdateTime(){
        return mSharedPreferences.getLong("lastUpdateTime", 0l);
    }
}
