package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;
import cn.bmob.v3.datatype.BmobDate;

/**
 * 赛事表
 * @author venus
 *
 */
public class Tournament extends BmobObject{

	/**
	 * 
	 */
	private static final long serialVersionUID = 4838967585109715959L;
	private String name;
	private BmobDate event_date;
	private BmobDate start_time;
	private BmobDate end_time;
	private String city;
	private String site;
	private Integer nature;
	private boolean state;
	private League league;
	private Team home_court;
	private Team opponent;
	private String score;
	private String score_h;
	private String score_h2;
	private String score_o;
	private String score_o2;
	private boolean isVerify;
	private Group group;
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public BmobDate getEvent_date() {
		return event_date;
	}
	public void setEvent_date(BmobDate event_date) {
		this.event_date = event_date;
	}
	public BmobDate getStart_time() {
		return start_time;
	}
	public void setStart_time(BmobDate start_time) {
		this.start_time = start_time;
	}
	public BmobDate getEnd_time() {
		return end_time;
	}
	public void setEnd_time(BmobDate end_time) {
		this.end_time = end_time;
	}
	
	
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public String getSite() {
		return site;
	}
	public void setSite(String site) {
		this.site = site;
	}
	public int getNature() {
		return nature;
	}
	public void setNature(int nature) {
		this.nature = nature;
	}
	public boolean isState() {
		return state;
	}
	public void setState(boolean state) {
		this.state = state;
	}
	public League getLeague() {
		return league;
	}
	public void setLeague(League league) {
		this.league = league;
	}
	public Team getHome_court() {
		return home_court;
	}
	public void setHome_court(Team home_court) {
		this.home_court = home_court;
	}
	public Team getOpponent() {
		return opponent;
	}
	public void setOpponent(Team opponent) {
		this.opponent = opponent;
	}
	public String getScore_h() {
		return score_h;
	}
	public void setScore_h(String score_h) {
		this.score_h = score_h;
	}
	public String getScore_o() {
		return score_o;
	}
	public void setScore_o(String score_o) {
		this.score_o = score_o;
	}
	
	public String getScore_h2() {
		return score_h2;
	}
	public void setScore_h2(String score_h2) {
		this.score_h2 = score_h2;
	}
	public String getScore_o2() {
		return score_o2;
	}
	public void setScore_o2(String score_o2) {
		this.score_o2 = score_o2;
	}
	public boolean isVerify() {
		return isVerify;
	}
	public void setVerify(boolean isVerify) {
		this.isVerify = isVerify;
	}
	public Group getGroup() {
		return group;
	}
	public void setGroup(Group group) {
		this.group = group;
	}
	@Override
	public String toString() {
		return "Tournament [name=" + name + ", event_date=" + event_date
				+ ", start_time=" + start_time + ", end_time=" + end_time
				+ ", city=" + city + ", site=" + site + ", nature=" + nature
				+ ", state=" + state + ", league=" + league + ", home_court="
				+ home_court + ", opponent=" + opponent + ", score=" + score
				+ ", score_h=" + score_h + ", score_h2=" + score_h2
				+ ", score_o=" + score_o + ", score_o2=" + score_o2
				+ ", isVerify=" + isVerify + ", group=" + group + "]";
	}
	
}
