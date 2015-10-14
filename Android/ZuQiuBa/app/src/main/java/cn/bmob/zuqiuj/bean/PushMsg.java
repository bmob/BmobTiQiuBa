package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;

/**
 * Created by BaiKing Rio on 2015/1/31.
 * IOS客户端需要将推送消息存到服务端再进行拉数据，故需要此类
 */
public class PushMsg extends BmobObject{
    private String belongUsername;//谁接收填谁的手机号
    private String content;//PushMessage表中的title字段
    private String extra;
    private int isRead;
    private int status;
    private int msgType;
    private String belongId;
    private String belongNick;

    public PushMsg(){}

    public PushMsg(String belongUsername,String content,String extra){
        this.belongUsername = belongUsername;
        this.content = content;
        this.extra = extra;
        this.isRead = 0;//未读
        this.status = 0;
        this.msgType=0;
    }

    public String getExtra() {
        return extra;
    }

    public void setExtra(String extra) {
        this.extra = extra;
    }

    public String getBelongId() {
        return belongId;
    }

    public void setBelongId(String belongId) {
        this.belongId = belongId;
    }

    public String getBelongNick() {
        return belongNick;
    }

    public void setBelongNick(String belongNick) {
        this.belongNick = belongNick;
    }

    public String getBelongUsername() {
        return belongUsername;
    }

    public void setBelongUsername(String belongUsername) {
        this.belongUsername = belongUsername;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getIsRead() {
        return isRead;
    }

    public void setIsRead(int isRead) {
        this.isRead = isRead;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getMsgType() {
        return msgType;
    }

    public void setMsgType(int msgType) {
        this.msgType = msgType;
    }
}
