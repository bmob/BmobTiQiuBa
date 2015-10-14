package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;

public class TeamScore extends BmobObject{

	/**
	 * 赛事积分表
	 */
	private static final long serialVersionUID = 4242695799591659778L;

	private String name;
	private League league;
	private Tournament competition;
	private Team team;

    //胜平负
	private boolean win;
	private boolean draw;
	private boolean loss;

	private Integer goals;
	private Integer goals_against;
	private Integer goal_difference;
	private Integer points;
	private Integer score;

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
	public boolean getWin() {
		return win;
	}
	public void setWin(boolean win) {
		this.win = win;
	}
	public boolean getDraw() {
		return draw;
	}
	public void setDraw(boolean draw) {
		this.draw = draw;
	}
	public boolean getLoss() {
		return loss;
	}
	public void setLoss(boolean loss) {
		this.loss = loss;
	}

	public int getGoals() {
		return goals;
	}
	public void setGoals(int goals) {
		this.goals = goals;
	}
	public int getGoals_against() {
		return goals_against;
	}
	public void setGoals_against(int goals_against) {
		this.goals_against = goals_against;
	}
	public int getGoal_difference() {
		return goal_difference;
	}
	public void setGoal_difference(int goal_difference) {
		this.goal_difference = goal_difference;
	}
	public int getPoints() {
		return points;
	}
	public void setPoints(int points) {
		this.points = points;
	}
	public int getScore() {
		return score;
	}
	public void setScore(int score) {
		this.score = score;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	
}
