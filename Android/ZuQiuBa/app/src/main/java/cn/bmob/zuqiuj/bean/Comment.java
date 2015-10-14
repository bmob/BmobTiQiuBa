package cn.bmob.zuqiuj.bean;

import cn.bmob.v3.BmobObject;

public class Comment extends BmobObject{

	/**
	 * 球员评分表
	 */
	private static final long serialVersionUID = 1295989145615258788L;

	private User accept_comm;
	private User komm;
	private int score;
	private String comment;
	private Tournament competition;
	
	public User getAccept_comm() {
		return accept_comm;
	}
	public void setAccept_comm(User accept_comm) {
		this.accept_comm = accept_comm;
	}
	public User getKomm() {
		return komm;
	}
	public void setKomm(User komm) {
		this.komm = komm;
	}
	public int getScore() {
		return score;
	}
	public void setScore(int score) {
		this.score = score;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	public Tournament getCompetition() {
		return competition;
	}
	public void setCompetition(Tournament competition) {
		this.competition = competition;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	
}
