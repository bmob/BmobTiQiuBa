package cn.bmob.zuqiuj.bean;

import android.text.TextUtils;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;

/**
 * 推送实体类
 * @author venus
 *	{
//	    aps =     {
//	        alert = "稻草人添加你为好友";
//	        badge = 0;
//	        sound = "";
//	    };
//      objectId = d9c25c975d;  PushMsg表的ID，用于唯一标示，用于防止推送信息和直接查询的数据重复
//	    belongId = 13760824455;
//	    flag = notice;
//	    subtype = 1;
//	    targetId = fwXuDDDP;
//	    time = 1409063138;
//	    title = "稻草人";
//	    type = 1;
//	}
 */
public class PushMessage implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1821200628237959902L;
	private int _id;//数据库id
    private Aps aps;//ios推送必须的字段
    private String objectId;//保存到PushMsg表后得到的objectId
    private String belongId;//谁发填谁的手机号
    private String title;//发送方的队名
    private String targetId;//根据类型组装targetId
    private int type;
    private int subtype;
    private String flag;//notice = "notice"标识 要显示在资讯栏
    private long time;
    private int status;//用于本地数据的更新标记
    private String extra;//额外字段--额外组装用于保存到PushMsg表中

    public PushMessage(){}

    /*
    * 创建推送的消息体
    * */
    public PushMessage(String alert,String belongId,String targetId,String title,int type,int subtype){
        Aps aps = new Aps();
        aps.setAlert(alert);
        this.aps = aps;
        this.belongId = belongId;
        this.targetId = targetId;
        this.title =title;
        this.subtype = subtype;
        this.type = type;
        this.status = 0;
    }
/*
* 创建约赛的消息体，约赛比较特殊，需要存储比赛相关的extra信息
* */
    public PushMessage(String alert,String belongId,String targetId,String title,int type,int subtype,String extra){
        Aps aps = new Aps();
        aps.setAlert(alert);
        this.aps = aps;
        this.belongId = belongId;
        this.targetId = targetId;
        this.title =title;
        this.subtype = subtype;
        this.type = type;
        this.status = 0;
        this.extra = extra;
    }

    /*
    * 根据取回来的PushMsg来创建消息体
    * */
    public PushMessage(PushMsg msg){
        Aps aps = new Aps();
        aps.setAlert(msg.getContent());
        this.aps = aps;
        this.status = msg.getStatus();
        String extra = msg.getExtra();
        try{
            JSONObject obj = new JSONObject(extra);
            this.belongId = obj.getString("belongId");
            this.targetId =  obj.getString("targetId");
            this.title =obj.getString("title");
            this.subtype = obj.getInt("subtype");
            this.type = obj.getInt("type");
            this.time = obj.getLong("time");
            if(obj.has("extra")){//是否包含extra字段，只有约赛的消息才会有extra字段
                this.extra = obj.getString("extra");
            }
        }catch(Exception exc){
        }
    }

    /*
    * 当遇见约赛消息时，需要从PushMsg表查询出该条消息并获取extra的消息
    * */
    public String getExtra(){
        return  this.extra;
    }

	public int get_id() {
		return _id;
	}
	public void set_id(int _id) {
		this._id = _id;
	}
	public Aps getAps() {
		return aps;
	}
	public void setAps(Aps aps) {
		this.aps = aps;
	}
	public String getBelongId() {
		return belongId;
	}
	public void setBelongId(String belongId) {
		this.belongId = belongId;
	}
	
	
	public String getFlag() {
		return flag;
	}
	public void setFlag(String flag) {
		this.flag = flag;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public int getSubtype() {
		return subtype;
	}
	public void setSubtype(int subtype) {
		this.subtype = subtype;
	}
	public String getTargetId() {
		return targetId;
	}
	public void setTargetId(String targetId) {
		this.targetId = targetId;
	}
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}

    public void setExtra(String extra) {
        this.extra = extra;
    }
    public String getObjectId() {
        return objectId;
    }
    public void setObjectId(String objectId) {
        this.objectId = objectId;
    }


    //创建extra,用于保存到PushMsg表中，因为其extra字段是固定的，只有约赛比较特殊
    public String createExtra() {
        JSONObject json=new JSONObject();
        try {
            json.put("belongId", this.belongId);//发送方Id
            json.put("subtype", this.subtype);
            json.put("targetId", this.targetId);
            json.put("time", System.currentTimeMillis() / 1000);
            json.put("title", this.title);
            json.put("type", this.type);
            if(!TextUtils.isEmpty(this.extra)){//因为约赛的推送消息其extra里的内容比较特殊，需要将extra的消息存储到表中，但不需要放到推送消息里面
                Log.i("life","extra不为空，表明此为约赛消息");
                json.put("extra",this.extra);
            }
        }catch(JSONException ex){
        }
        return json.toString();
    }

    @Override
	public String toString() {
		return "PushMessage [_id=" + _id + ", alert=" + aps.getAlert() +",object = "+objectId+", belongId="
				+ belongId + ", flag=" + flag + ", status=" + status
				+ ", subtype=" + subtype + ", targetId=" + targetId + ", time="
				+ time + ", title=" + title + ", type=" + type + ", extra=" + extra + "]";
	}

    /*
    * 用于组装推送消息
    * */
    public String toJson(){
        JSONObject totalObject = new JSONObject();
        try {
            JSONObject aps = new JSONObject();
            aps.put("alert", this.aps.getAlert());
            aps.put("badge", 1);
            aps.put("sound ", "");
            totalObject.put("aps", aps);
            totalObject.put("flag", "notice");
            totalObject.put("belongId", this.belongId);//发送方Id
            totalObject.put("objectId", this.objectId);//此条消息的objectId
            totalObject.put("subtype", this.subtype);
            totalObject.put("targetId", this.targetId);
            totalObject.put("time", System.currentTimeMillis() / 1000);
            totalObject.put("title", this.title);
            totalObject.put("type", this.type);
        }catch(JSONException ex){
        }
        return totalObject.toString();
    }

}
