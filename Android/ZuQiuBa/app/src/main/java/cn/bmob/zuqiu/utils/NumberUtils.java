package cn.bmob.zuqiu.utils;

import java.math.BigDecimal;

public class NumberUtils {

	/**
	 * 控制float值的精度
	 * 
	 * 与小数位精度(四舍五入等)相关的一些常用工具方法.
	 * 
	 * 
	 * 
	 * float/double的精度取值方式分为以下几种: <br>
	 * 
	 * java.math.BigDecimal.ROUND_UP <br>
	 * 
	 * java.math.BigDecimal.ROUND_DOWN <br>
	 * 
	 * java.math.BigDecimal.ROUND_CEILING <br>
	 * 
	 * java.math.BigDecimal.ROUND_FLOOR <br>
	 * 
	 * java.math.BigDecimal.ROUND_HALF_UP<br>
	 * 
	 * java.math.BigDecimal.ROUND_HALF_DOWN <br>
	 * 
	 * java.math.BigDecimal.ROUND_HALF_EVEN <br>
	 * 
	 * @param value
	 * @param scale
	 * @param roundingMode
	 * @return
	 */
	public static double round(double value, int scale, int roundingMode) {

		BigDecimal bd = new BigDecimal(value);

		bd = bd.setScale(scale, roundingMode);

		double d = bd.doubleValue();

		bd = null;

		return d;

	}
}
