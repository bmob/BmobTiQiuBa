package cn.bmob.zuqiu.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import cn.bmob.v3.BmobUser;
import cn.bmob.zuqiu.db.DBConfig.DbUpdateListener;
import cn.bmob.zuqiuj.bean.Aps;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.User;

/**
 * Bmob数据库管理：目前本地数据库中的表：消息表、会话表、好友表、好友请求表
 * @ClassName: BmobDB
 * @Description: TODO
 * @author smile
 * @date 2014-5-29 下午9:14:19
 */
public class BmobDB {

	private static HashMap<String, BmobDB> daoMap = new HashMap<String, BmobDB>();

	private SQLiteDatabase db;

	/** 创建并打开BmobDB：默认打开以当前登录用户名为dbName的数据库，建议使用此方法打开数据库
	  * @Title: create
	  * @Description: TODO
	  * @param  context
	  * @param  
	  * @return BmobDB
	  * @throws
	  */
	public static BmobDB create(Context context) {
		DBConfig config = new DBConfig();
		config.setContext(context);
        config.setDbName(getCurrentObjectId(context));
		return getInstance(config);
	}

    /*
    * 以objectId为数据库名
    * */
    public static String getCurrentObjectId(Context context){
        User cur =  BmobUser.getCurrentUser(context, User.class);
        return cur!=null ?cur.getObjectId():"";
    }

	/** 创建指定dbname的数据库 --用于保存登陆过同一设备的多账户的消息
	  * @Title: create
	  * @Description: TODO
	  * @param  context
	  * @param  dbName
	  * @param  
	  * @return BmobDB
	  * @throws
	  */
	public static BmobDB create(Context context, String dbName) {
        DBConfig config = new DBConfig();
		config.setContext(context);
		config.setDbName(dbName);
		return getInstance(config);
	}
	

	/**
	 * 获取实例BmobDB
	 * @param daoConfig
	 * @return
	 */
	public static BmobDB getInstance(DBConfig daoConfig) {
		return init(daoConfig);
	}

	private synchronized static BmobDB init(DBConfig daoConfig) {
		BmobDB dao = daoMap.get(daoConfig.getDbName());
		if (dao == null) {
			dao = new BmobDB(daoConfig);
			daoMap.put(daoConfig.getDbName(), dao);
		}
		return dao;
	}

	private BmobDB(DBConfig config) {
		if (config == null)
			throw new RuntimeException("dbConfig is null");
		if (config.getContext() == null)
			throw new RuntimeException("android context is null");
		//获取指定dbname的数据库
		this.db = new SqliteDbHelper(config.getContext()
				.getApplicationContext(), config.getDbName(),
				config.getDbVersion(), config.getDbUpdateListener())
				.getWritableDatabase();
	}

	/**
	 * @return String
	 * @throws
	 */
	private void createOrCheckChatTable(SQLiteDatabase db) {
		db.execSQL("CREATE TABLE IF NOT EXISTS " + DBConstants.TableName.MESSAGE + " ("
				+ DBConstants.MessageColumn._ID + " INTEGER PRIMARY KEY AUTOINCREMENT, "// _id
				+ DBConstants.MessageColumn.ALERT + " TEXT, "//
				+ DBConstants.MessageColumn.NOTICE + " TEXT, "//
                + DBConstants.MessageColumn.STATUS + " INTEGER, "//
                + DBConstants.MessageColumn.TYPE + " INTEGER, "//
                + DBConstants.MessageColumn.SUBTYPE + " INTEGER, "//
                + DBConstants.MessageColumn.OBJECT_ID + " TEXT, "//
                + DBConstants.MessageColumn.BELONG_ID + " TEXT, "//
                + DBConstants.MessageColumn.TARGET_ID + " TEXT , "//
                + DBConstants.MessageColumn.TIME + " LONG, "//
                + DBConstants.MessageColumn.TITLE + " TEXT , "//
				+ DBConstants.MessageColumn.EXTRA + " TEXT); ");
	}
	
	/**
	  * @Title: getAllMessage
	  * @return List<PushMessage>
	  * @throws
	  */
	public List<PushMessage> getAllMessage() {
		List<PushMessage> list = new ArrayList<PushMessage>();
		if (db != null) {
			String sql = "SELECT * from " + DBConstants.TableName.MESSAGE  + " ORDER BY " + DBConstants.MessageColumn._ID + " DESC";
			Cursor cursor = db.rawQuery(sql, null);
            PushMessage msg =null;
            while(cursor.moveToNext()) {
                Aps aps = new Aps();
                aps.setAlert(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.ALERT)));
                msg = new PushMessage();
                msg.setAps(aps);
                msg.set_id(cursor.getInt(cursor.getColumnIndex(DBConstants.MessageColumn._ID)));
                msg.setBelongId(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.BELONG_ID)));
                msg.setObjectId(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.OBJECT_ID)));
                msg.setFlag(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.NOTICE)));
                msg.setStatus(cursor.getInt(cursor.getColumnIndex(DBConstants.MessageColumn.STATUS)));
                msg.setSubtype(cursor.getInt(cursor.getColumnIndex(DBConstants.MessageColumn.SUBTYPE)));
                msg.setTargetId(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.TARGET_ID)));
                msg.setTime(cursor.getLong(cursor.getColumnIndex(DBConstants.MessageColumn.TIME)));
                msg.setTitle(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.TITLE)));
                msg.setType(cursor.getInt(cursor.getColumnIndex(DBConstants.MessageColumn.TYPE)));
                msg.setExtra(cursor.getString(cursor.getColumnIndex(DBConstants.MessageColumn.EXTRA)));
                list.add(msg);
			}
			
			if (cursor != null && !cursor.isClosed()) {
                cursor.close();
                cursor = null;
			}
		}
		return list;
	}

    /*
   * 更新status的状态
   * */
    public void update(int index,int value){
        String where = DBConstants.MessageColumn._ID+"=?";
        String[] whereArgs = {Integer.toString(index)};
        ContentValues cv = new ContentValues();
        cv.put(DBConstants.MessageColumn.STATUS, value);
        db.update(DBConstants.TableName.MESSAGE, cv, where, whereArgs);
    }

	/** 删除全部
	  * @Title: deleteMessages
	  * @return
	  * @throws
	  */
	public void deleteAllMessages() {
        if(db.isOpen()) {
            db.delete(DBConstants.TableName.MESSAGE, null, null);
        }
	}
    /**
    * 删除单条消息
    * */
    public void deleteMessage(int deleteId){
        String where = DBConstants.MessageColumn._ID+"=?";
        String[] whereArgs = {Integer.toString(deleteId)};
        db.delete(DBConstants.TableName.MESSAGE, where, whereArgs);
    }


	/** 保存聊天消息 saveMessage
	  * @Title: saveMessage
	  * @return int
	  * @throws
	  */
	public int insertMessage(PushMessage msg) {
		int id = -1;
		if (db.isOpen()) {
            ContentValues cv = new ContentValues();
            cv.put(DBConstants.MessageColumn.ALERT, msg.getAps().getAlert());
            cv.put(DBConstants.MessageColumn.OBJECT_ID, msg.getObjectId());
            cv.put(DBConstants.MessageColumn.BELONG_ID, msg.getBelongId());
            cv.put(DBConstants.MessageColumn.NOTICE, msg.getFlag());
            cv.put(DBConstants.MessageColumn.STATUS, msg.getStatus());
            cv.put(DBConstants.MessageColumn.SUBTYPE, msg.getSubtype());
            cv.put(DBConstants.MessageColumn.TARGET_ID, msg.getTargetId());
            cv.put(DBConstants.MessageColumn.TIME, msg.getTime());
            cv.put(DBConstants.MessageColumn.TITLE,msg.getTitle());
            cv.put(DBConstants.MessageColumn.TYPE, msg.getType());
            if(msg.getExtra()!=null){
                cv.put(DBConstants.MessageColumn.EXTRA, msg.getExtra());
            }
			if(!checkTargetMsgExist(msg.getTargetId(), msg.getTime())){//不存在则插入
				db.insert(DBConstants.TableName.MESSAGE, null, cv);
			}else{//更新指定消息的内容、状态、头像
				db.update(DBConstants.TableName.MESSAGE, cv,null, null);
			}
			// 插入成功
			Cursor c = db.rawQuery("select last_insert_rowid() from "+ DBConstants.TableName.MESSAGE, null);
			if (c.moveToFirst()) {
				id = c.getInt(0);
			}
			if (c != null && !c.isClosed()) {
				c.close();
				c = null;
            }
		}
		return id;
	}


    /** 检查指定消息是否存在
     * @Title: checkTargetMsgExist
     * @Description: TODO
     * @param
     * @return
     * @throws
     */
    public boolean checkTargetMsgExist(String conversionId,long msgTime){
        String[] args = new String[] { conversionId,String.valueOf(msgTime)};
        Cursor c = db.query(DBConstants.TableName.MESSAGE, null, DBConstants.MessageColumn.TARGET_ID + " = ?  AND "+ DBConstants.MessageColumn.TIME + " = ? ",args, null, null, null);
        boolean isTrue =false;
        try {
            isTrue = c.moveToFirst();
        }finally{
            if (c != null) {
                c.close();
                c = null;
            }
        }
        return isTrue;
    }

	// 初始化时创建数据库
	class SqliteDbHelper extends SQLiteOpenHelper {

		private DbUpdateListener mDbUpdateListener;
		Context context;
		public SqliteDbHelper(Context context, String name, int version,
				DbUpdateListener dbUpdateListener) {
			super(context, name, null, version);
			this.mDbUpdateListener = dbUpdateListener;
			this.context =context;
		}

		@Override
		public void onCreate(SQLiteDatabase db) {
			// 创建消息表
			createOrCheckChatTable(db);
		}

		@Override
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			if (mDbUpdateListener != null) {
				mDbUpdateListener.onUpgrade(db, oldVersion, newVersion);
			} else { // 清空所有的数据信息
				BmobDB.create(context).clearAllDbCache();
				// 重新创建
//				db.execSQL(ADD_INVITE_COLUMN);
			}
		}
	}

	/**数据库升级时,删除所有数据表
	  * 用于清空缓存操作--谨慎使用
	  * @Title: clearAllDbCache
	  * @Description: TODO
	  * @return 
	  * @throws
	  */
	public void clearAllDbCache() {
		Cursor cursor = db.rawQuery("SELECT name FROM sqlite_master WHERE type ='table' AND name != 'sqlite_sequence'",	null);
		if (cursor != null) {
			while (cursor.moveToNext()) {
				db.execSQL("DROP TABLE " + cursor.getString(0));
			}
		}
		if (cursor != null) {
			cursor.close();
			cursor = null;
		}
	}

}
