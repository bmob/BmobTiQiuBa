package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;

public class LeaguePlayerStat extends BmobObject{
	/**
	 * 
	 */
	private static final long serialVersionUID = 8047194219820415497L;
	private String league;
	private User player;
	private String team;
	private int goals;
	private int assists;
	public String getLeague() {
		return league;
	}
	public void setLeague(String league) {
		this.league = league;
	}
	public User getPlayer() {
		return player;
	}
	public void setPlayer(User player) {
		this.player = player;
	}
	public String getTeam() {
		return team;
	}
	public void setTeam(String team) {
		this.team = team;
	}
	public int getGoals() {
		return goals;
	}
	public void setGoals(int goals) {
		this.goals = goals;
	}
	public int getAssists() {
		return assists;
	}
	public void setAssists(int assists) {
		this.assists = assists;
	}
	
	
}	
