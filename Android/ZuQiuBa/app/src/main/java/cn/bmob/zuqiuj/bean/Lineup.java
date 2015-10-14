package cn.bmob.zuqiuj.bean;

import android.provider.ContactsContract.CommonDataKinds.Relation;
import cn.bmob.v3.BmobObject;
import cn.bmob.v3.datatype.BmobRelation;

public class Lineup extends BmobObject{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1404188210348295690L;
	/**
	 * 球队
	 */
	private Team team;
	/**后卫*/
	private BmobRelation back;
	/**中锋*/
	private BmobRelation striker;
	/**前锋*/
	private BmobRelation forward;
	/**守门员*/
	private User goalkeeper;
	public Team getTeam() {
		return team;
	}
	public void setTeam(Team team) {
		this.team = team;
	}
	
	
	public BmobRelation getBack() {
		return back;
	}
	public void setBack(BmobRelation back) {
		this.back = back;
	}
	public BmobRelation getStriker() {
		return striker;
	}
	public void setStriker(BmobRelation striker) {
		this.striker = striker;
	}
	public BmobRelation getForward() {
		return forward;
	}
	public void setForward(BmobRelation forward) {
		this.forward = forward;
	}
	public User getGoalkeeper() {
		return goalkeeper;
	}
	public void setGoalkeeper(User goalkeeper) {
		this.goalkeeper = goalkeeper;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	
}
