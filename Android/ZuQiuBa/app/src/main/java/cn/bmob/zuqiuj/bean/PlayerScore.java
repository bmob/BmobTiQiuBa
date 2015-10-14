package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;

public class PlayerScore extends BmobObject{

	/**
	 * 球员赛事积分表
	 */
	private static final long serialVersionUID = 3942421481321855167L;

	private User player;
	private League league;
	private Tournament competition;
	private Team team;
	private float avg;
	private Integer goals;
	private Integer assists;
	public User getPlayer() {
		return player;
	}
	public void setPlayer(User player) {
		this.player = player;
	}
	public League getLeague() {
		return league;
	}
	public void setLeague(League league) {
		this.league = league;
	}
	public Tournament getCompetition() {
		return competition;
	}
	public void setCompetition(Tournament competition) {
		this.competition = competition;
	}
	public Team getTeam() {
		return team;
	}
	public void setTeam(Team team) {
		this.team = team;
	}
	public float getAvg() {
		return avg;
	}
	public void setAvg(float avg) {
		this.avg = avg;
	}
	public Integer getGoals() {
		return goals;
	}
	public void setGoals(Integer goals) {
		this.goals = goals;
	}
    public Integer getAssists() {
        return assists;
    }

    public void setAssists(Integer assists) {
        this.assists = assists;
    }
	public static long getSerialversionuid() {
		return serialVersionUID;
	}


}
