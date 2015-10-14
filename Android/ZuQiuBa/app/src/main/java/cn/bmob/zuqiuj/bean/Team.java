package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.datatype.BmobFile;
import cn.bmob.v3.datatype.BmobRelation;

public class Team extends BmobObject{

	
	/**
	 * 
	 */
	private static final long serialVersionUID = 7354167945661745761L;
	private String name;
	private BmobFile avator;
	private String city;
	private BmobDate found_time;
	private String gsl_code;
    private String reg_code;
	private User captain;
	private String about;
	private BmobRelation footballer;
	private Integer appearances;
	private Integer appearancesTotal;
	private Integer win;
	private Integer winTotal;
	private Integer draw;
	private Integer drawTotal;
	private Integer loss;
	private Integer lossTotal;
	private Integer goals;
	private Integer goalsTotal;
	private Integer goals_against;
	private Integer goalsAgainstTotal;
	private Integer goal_difference;
	private Integer goalDifferenceTotal;
	private String cityname;

	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public BmobFile getAvator() {
		return avator;
	}
	public void setAvator(BmobFile avator) {
		this.avator = avator;
	}
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public BmobDate getFound_time() {
		return found_time;
	}
	public void setFound_time(BmobDate found_time) {
		this.found_time = found_time;
	}
	public String getGsl_code() {
		return gsl_code;
	}
	public void setGsl_code(String gsl_code) {
		this.gsl_code = gsl_code;
	}
	public User getCaptain() {
		return captain;
	}
	public void setCaptain(User captain) {
		this.captain = captain;
	}
	public String getAbout() {
		return about;
	}
	public void setAbout(String about) {
		this.about = about;
	}
	public BmobRelation getFootballer() {
		return footballer;
	}
	public void setFootballer(BmobRelation footballer) {
		this.footballer = footballer;
	}
	public Integer getAppearances() {
		return appearances;
	}
	public void setAppearances(Integer appearances) {
		this.appearances = appearances;
	}
	public Integer getWin() {
		return win;
	}
	public void setWin(Integer win) {
		this.win = win;
	}
	public Integer getDraw() {
		return draw;
	}
	public void setDraw(Integer draw) {
		this.draw = draw;
	}
	public Integer getLoss() {
		return loss;
	}
	public void setLoss(Integer loss) {
		this.loss = loss;
	}
	public Integer getGoals() {
		return goals;
	}
	public void setGoals(Integer goals) {
		this.goals = goals;
	}
	public Integer getGoals_against() {
		return goals_against;
	}
	public void setGoals_against(Integer goals_against) {
		this.goals_against = goals_against;
	}
	public Integer getGoal_difference() {
		return goal_difference;
	}
	public void setGoal_difference(Integer goal_difference) {
		this.goal_difference = goal_difference;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	public String getCityname() {
		return cityname;
	}
	public void setCityname(String cityname) {
		this.cityname = cityname;
	}
	public Integer getAppearancesTotal() {
		return appearancesTotal;
	}
	public void setAppearancesTotal(Integer appearancesTotal) {
		this.appearancesTotal = appearancesTotal;
	}
	public Integer getWinTotal() {
		return winTotal;
	}
	public void setWinTotal(Integer winTotal) {
		this.winTotal = winTotal;
	}
	public Integer getDrawTotal() {
		return drawTotal;
	}
	public void setDrawTotal(Integer drawTotal) {
		this.drawTotal = drawTotal;
	}
	public Integer getLossTotal() {
		return lossTotal;
	}
	public void setLossTotal(Integer lossTotal) {
		this.lossTotal = lossTotal;
	}
	public Integer getGoalsTotal() {
		return goalsTotal;
	}
	public void setGoalsTotal(Integer goalsTotal) {
		this.goalsTotal = goalsTotal;
	}
	public Integer getGoalsAgainstTotal() {
		return goalsAgainstTotal;
	}
	public void setGoalsAgainstTotal(Integer goalsAgainstTotal) {
		this.goalsAgainstTotal = goalsAgainstTotal;
	}
	public Integer getGoalDifferenceTotal() {
		return goalDifferenceTotal;
	}
	public void setGoalDifferenceTotal(Integer goalDifferenceTotal) {
		this.goalDifferenceTotal = goalDifferenceTotal;
	}

    public String getReg_code() {
        return reg_code;
    }

    public void setReg_code(String reg_code) {
        this.reg_code = reg_code;
    }
}
