package cn.bmob.zuqiuj.bean;

import android.content.Context;
import cn.bmob.v3.BmobInstallation;

public class MyInstallation extends BmobInstallation{

	/**
	 * 
	 */
	private static final long serialVersionUID = -5644125310532157102L;

	public MyInstallation(Context arg0) {
		super(arg0);
		// TODO Auto-generated constructor stub
	}

	private String uid;

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}
	
	
	
}
