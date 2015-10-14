package cn.bmob.zuqiu.utils;

public class UserHelper {
	
	
	
	/**
     * 根据枚举值返回球员场上位置
     * @param location
     * @return
     */
	public static String getUserLocation(Integer location){
        if(location == null){
            return "";
        }
		switch (location) {
		case 1:
			return "门将";
		case 2:
			return "后卫";
		case 3:
			return "中场";
		case 4:
			return "前锋";
		default:
			break;
		}
		return "前锋";
	}
	
	
	/**
	 * 根据枚举值返回擅长脚
	 * @param leg
	 * @return
	 */
	public static String getGoodat(int leg){
		switch (leg) {
		case 1:
			return "左脚";
		case 2:
			return "右脚";
		case 3:
			return "左右开弓";
		case 4:
			break;
		}
		return "左脚";
	}
}
