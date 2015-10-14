package cn.bmob.zuqiu.view.sortlistview;

import java.util.Comparator;

import cn.bmob.zuqiuj.bean.City;


/**
 * 
 * @author xiaanming
 *
 */
public class PinyinComparator implements Comparator<City> {

	public int compare(City o1, City o2) {
		if (o1.getSortLetter().equals("@")
				|| o2.getSortLetter().equals("#")) {
			return -1;
		} else if (o1.getSortLetter().equals("#")
				|| o2.getSortLetter().equals("@")) {
			return 1;
		} else {
			return o1.getSortLetter().compareTo(o2.getSortLetter());
		}
	}

}
