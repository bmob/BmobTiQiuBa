package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.datatype.BmobFile;
import cn.bmob.v3.datatype.BmobRelation;

public class User extends BmobUser{

	/**
	 * 
	 */
	private static final long serialVersionUID = 841887000047755970L;
	
	private String nickname;
	private BmobFile avator;
	private String invitation;
	private BmobDate birthday;
	private Integer midfielder;
	private Integer be_good;
	private float height;
	private float weight;
	private String city;
	private Integer games;
	private Integer gamesTotal;
	
	private Integer goals;
	private Integer goalsTotal;
	
	private Integer assists;
	private Integer assistsTotal;
	
	private float score;
	private BmobRelation friends;
    private String installId;
    private String cityname;
    
    private String pushUserId;
    private String pushChannelId;
    private String deviceType;

    public Integer getGamesTotal() {
		return gamesTotal;
	}
	public void setGamesTotal(Integer gamesTotal) {
		this.gamesTotal = gamesTotal;
	}
	public Integer getGoalsTotal() {
		return goalsTotal;
	}
	public void setGoalsTotal(Integer goalsTotal) {
		this.goalsTotal = goalsTotal;
	}
	public Integer getAssists() {
		return assists;
	}
	public void setAssists(Integer assists) {
		this.assists = assists;
	}
	public Integer getAssistsTotal() {
		return assistsTotal;
	}
	public void setAssistsTotal(Integer assistsTotal) {
		this.assistsTotal = assistsTotal;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public BmobFile getAvator() {
		return avator;
	}
	public void setAvator(BmobFile avator) {
		this.avator = avator;
	}
	public String getInvitation() {
		return invitation;
	}
	public void setInvitation(String invitation) {
		this.invitation = invitation;
	}
	public BmobDate getBirthday() {
		return birthday;
	}
	public void setBirthday(BmobDate birthday) {
		this.birthday = birthday;
	}
	public Integer getMidfielder() {
		return midfielder;
	}
	public void setMidfielder(Integer midfielder) {
		this.midfielder = midfielder;
	}
	public Integer getBe_good() {
		return be_good;
	}
	public void setBe_good(Integer be_good) {
		this.be_good = be_good;
	}
	public float getHeight() {
		return height;
	}
	public void setHeight(float height) {
		this.height = height;
	}
	public float getWeight() {
		return weight;
	}
	public void setWeight(float weight) {
		this.weight = weight;
	}
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public Integer getGames() {
		return games;
	}
	public void setGames(Integer games) {
		this.games = games;
	}
	public Integer getGoals() {
		return goals;
	}
	public void setGoals(Integer goals) {
		this.goals = goals;
	}
	public float getScore() {
		return score;
	}
	public void setScore(float score) {
		this.score = score;
	}
	public BmobRelation getFriends() {
		return friends;
	}
	public void setFriends(BmobRelation friends) {
		this.friends = friends;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	public String getInstallId() {
		return installId;
	}
	public void setInstallId(String installId) {
		this.installId = installId;
	}
	public String getCityname() {
		return cityname;
	}
	public void setCityname(String cityname) {
		this.cityname = cityname;
	}

    public String getPushUserId() {
        return pushUserId;
    }

    public void setPushUserId(String pushUserId) {
        this.pushUserId = pushUserId;
    }

    public String getPushChannelId() {
        return pushChannelId;
    }

    public void setPushChannelId(String pushChannelId) {
        this.pushChannelId = pushChannelId;
    }

    public String getDeviceType() {
        return deviceType;
    }

    public void setDeviceType(String deviceType) {
        this.deviceType = deviceType;
    }

    @Override
	public boolean equals(Object o) {
		// TODO Auto-generated method stub
		if(o instanceof User){
			User u = (User)o;
			return this.getObjectId().equals(u.getObjectId());
		}
		return super.equals(o);
	}
	
}
