package cn.bmob.zuqiu.utils;

public interface Constant {
	String BMOB_APP_ID = "";
	String BMOB_AVATAR_DIR = "/sdcard/Android/data/cn.bmob.zuqiu/avatar/";

	int REQUESTCODE_UPLOADAVATAR_CAMERA = 0;
	int REQUESTCODE_UPLOADAVATAR_CROP = 1;
	int REQUESTCODE_UPLOADAVATAR_LOCATION = 2;
	
	int COMPETITION_NEAR = 0;
	int COMPETITION_MY = 1;
	int COMPETITION_CURRENT_TEAM = 2;
	
	int RECORD_MY = 3;//我的战绩
	int RECORD_OTHER = 4;//他人的战绩
	int RECORD_MYTEAM = 5;//我的球队
	int RECORD_OTHERTEAM = 6;//别的球队

    String ACTION_TEAM_QUIT_UPDATE="com.bmob.zuqiu.quit";//退出球队/解散球队发出的广播，请求更新页面
}
