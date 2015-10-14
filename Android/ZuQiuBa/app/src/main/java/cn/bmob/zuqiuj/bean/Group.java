package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;
import cn.bmob.v3.datatype.BmobRelation;

public class Group extends BmobObject{
	/**
	 * 
	 */
	private static final long serialVersionUID = -5907500582333502488L;
	private String name;
	private League league;
	private BmobRelation teams;
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public League getLeague() {
		return league;
	}
	public void setLeague(League league) {
		this.league = league;
	}
	public BmobRelation getTeams() {
		return teams;
	}
	public void setTeams(BmobRelation teams) {
		this.teams = teams;
	}
	
	
}
