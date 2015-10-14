package cn.bmob.zuqiuj.bean;

import java.io.Serializable;

/**
 * 消息标题实体，跟ios一致
 * @author venus
 *
 */
public class Aps implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = -115960602474212072L;
	private String alert;
	private int badge;
	private String sound;

	public String getAlert() {
		return alert;
	}
	public void setAlert(String alert) {
		this.alert = alert;
	}
	public int getBadge() {
		return badge;
	}
	public void setBadge(int badge) {
		this.badge = badge;
	}
	public String getSound() {
		return sound;
	}
	public void setSound(String sound) {
		this.sound = sound;
	}
	@Override
	public String toString() {
		return "Aps [alert=" + alert + ", badge=" + badge + ", sound=" + sound
				+ "]";
	}
	
	
}
