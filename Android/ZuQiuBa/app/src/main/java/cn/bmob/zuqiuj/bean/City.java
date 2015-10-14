package cn.bmob.zuqiuj.bean;

import java.io.Serializable;

public class City implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 7712274365285104822L;
	private int city_id;
	private String city_name;
	private String pinyin;
	private String sortLetter;
	private String cityId = "";
	
	public String getCityId() {
		return cityId;
	}
	public void setCityId(String cityId) {
		this.cityId = cityId;
	}
	public int getCity_id() {
		return city_id;
	}
	public void setCity_id(int city_id) {
		this.city_id = city_id;
	}
	public String getCity_name() {
		return city_name;
	}
	public void setCity_name(String city_name) {
		this.city_name = city_name;
	}
	public String getPinyin() {
		return pinyin;
	}
	public void setPinyin(String pinyin) {
		this.pinyin = pinyin;
	}
	public String getSortLetter() {
		return sortLetter;
	}
	public void setSortLetter(String sortLetter) {
		this.sortLetter = sortLetter;
	}
	@Override
	public String toString() {
		return "City [city_id=" + city_id + ", city_name=" + city_name
				+ ", pinyin=" + pinyin + ", sortLetter=" + sortLetter
				+ ", cityId=" + cityId + "]";
	}

	
	
}
