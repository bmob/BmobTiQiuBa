package cn.bmob.zuqiuj.bean;

import java.util.List;

import cn.bmob.v3.BmobObject;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.datatype.BmobRelation;

public class League extends BmobObject{

	/**
	 * 
	 */
	private static final long serialVersionUID = 6272278023468262255L;

	private String name;
	private String city;
	private List<String> playground;
	private int people;
	private int group_count;
	private boolean knockout;
	private String notes;
	private User master;
	private BmobRelation teams;
	private BmobDate start_time;
	private BmobDate end_time;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public List<String> getPlayground() {
		return playground;
	}
	public void setPlayground(List<String> playground) {
		this.playground = playground;
	}
	public int getPeople() {
		return people;
	}
	public void setPeople(int people) {
		this.people = people;
	}
	public int getGroup_count() {
		return group_count;
	}
	public void setGroup_count(int group_count) {
		this.group_count = group_count;
	}
	public boolean isKnockout() {
		return knockout;
	}
	public void setKnockout(boolean knockout) {
		this.knockout = knockout;
	}
	public String getNotes() {
		return notes;
	}
	public void setNotes(String notes) {
		this.notes = notes;
	}
	public User getMaster() {
		return master;
	}
	public void setMaster(User master) {
		this.master = master;
	}
	public BmobRelation getTeams() {
		return teams;
	}
	public void setTeams(BmobRelation teams) {
		this.teams = teams;
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
	
	
	
}
