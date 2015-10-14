package cn.bmob.zuqiu.db;

import android.provider.BaseColumns;

public interface DBConstants {

	String DATA_BASE_NAME = "zuqiu";
	int DATA_BASE_VERSION  = 1;

	public interface TableName{
		String MESSAGE = "message";
	}
	
	public interface MessageColumn extends BaseColumns{
		String ALERT = "alert";
        String OBJECT_ID="objectId";
        String BELONG_ID = "belongId";
        String TARGET_ID = "targetId";
        String NOTICE = "flag";
        String STATUS = "status";
        String SUBTYPE = "subtype";
		String TIME = "time";
		String TITLE = "title";
		String TYPE = "type";
        String EXTRA = "extra";
	}
	
}
