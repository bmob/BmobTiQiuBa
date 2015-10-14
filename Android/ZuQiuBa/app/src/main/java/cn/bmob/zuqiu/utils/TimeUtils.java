package cn.bmob.zuqiu.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import cn.bmob.v3.datatype.BmobDate;

public class TimeUtils {

    /**
     * 返回当前月和日
     * @return
     */
    public static String getCurrentMonthAndDay(){
        SimpleDateFormat sdf=new SimpleDateFormat("MM月dd日");
        String date=sdf.format(new Date());
        return date;
    }
	
	/**
	 * 返回当前年份
	 * @return
	 */
	public static String getCurrentYear(){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy");    
		String date=sdf.format(new Date());
		return date;
	}
	
	public static String getCurrentYear(BmobDate date){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
		Date dat = null;
		try {
			dat = sdf.parse(date.getDate());
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(dat);
		
		String datestr=calendar.get(Calendar.YEAR)+"年";
		return datestr;
	}
	public static int getCurrentYearNumber(BmobDate date){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
		Date dat = null;
		try {
			dat = sdf.parse(date.getDate());
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(dat);
		
		int datestr=calendar.get(Calendar.YEAR);
		return datestr;
	}
	
	public static String getCompetitionDate(BmobDate bmobDate){
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date date = format.parse(bmobDate.getDate());
			SimpleDateFormat sdf2 = new SimpleDateFormat("MM月dd日");
			String str = sdf2.format(date);
			return str;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	public static String getZhanjiDate(BmobDate bmobDate){
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date date = format.parse(bmobDate.getDate());
			SimpleDateFormat sdf2 = new SimpleDateFormat("MM/dd HH:mm");
			String str = sdf2.format(date);
			return str;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	public static String getSaichengDate(BmobDate bmobDate){
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date date = format.parse(bmobDate.getDate());
			SimpleDateFormat sdf2 = new SimpleDateFormat("MM/dd HH:mm");
			String str = sdf2.format(date);
			return str;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	
	public static String getCompetitionTime(BmobDate bmobDate){
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date date = format.parse(bmobDate.getDate());
			SimpleDateFormat sdf2 = new SimpleDateFormat("HH:mm");
			String str = sdf2.format(date);
			return str;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	/**
	 * 返回2014.xx.xx这种格式的时间。用于比赛页
	 * @param bmobDate
	 * @return
	 */
	public static String getTimeByBmobDate(BmobDate bmobDate){
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date date = format.parse(bmobDate.getDate());
			SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy.MM.dd");
			String str = sdf2.format(date);
			return str;
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	
	/**
	 * 根据当前毫秒数返回相应字符串
	 * @param time
	 * @return
	 */
	public static String getTimeByLong(long time){
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
		String date = sdf.format(new Date(time));
		return date;
	}
	
	public static Date getDateByString(String dateString){
		java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(
				"yyyy-MM-dd HH:mm:ss");
		java.util.Date beginDate = null;
		try {
			//出生年月
			beginDate = format.parse(dateString);
			return beginDate;
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}
    
    public static Date getDateByString2(long dateLong){
        return  new Date(dateLong);
    }
	
	/**
	 * 根據日期獲得年齡
	 */
	public static int getAgeByDate(BmobDate birthDate){

		if(birthDate == null){
			return 0;
		}
		java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(
				"yyyy-MM-dd HH:mm:ss");
		java.util.Date beginDate = null;
		try {
			//出生年月
			beginDate = format.parse(birthDate.getDate());
		} catch (ParseException e) {
			e.printStackTrace();
		}
		java.util.Date endDate = null;
		try {
		    //现在时间
			endDate = format.parse(new BmobDate(new Date()).getDate());
		} catch (ParseException e) {
			e.printStackTrace();
		}
		long day = (endDate.getTime() - beginDate.getTime()) / 1000;
		return (int) (day / (60 * 60 * 24 * 365));
	}


    /**
     * 将字符串转为时间戳
     * @param user_time
     * @return
     */
    public static String getTime(String user_time) {
        String re_time = null;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date d;
        try {
            d = sdf.parse(user_time);
            long l = d.getTime();
            String str = String.valueOf(l);
            re_time = str.substring(0, 10);
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return re_time;
    }

    /**
     * 比较当前时间
     * 如果当前时间大于比较的时间则返回true，否则返回false
     * @param bmobDate 比较的时间
     * @return
     */
    public static boolean compareCurrentTime(BmobDate bmobDate){
        try {
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = df.parse(bmobDate.getDate());
			Date now = df.parse(df.format(new Date(System.currentTimeMillis())));
            return now.getTime() > date.getTime();
        } catch (ParseException e) {
            e.printStackTrace();
            return false;
        }
    }
}
