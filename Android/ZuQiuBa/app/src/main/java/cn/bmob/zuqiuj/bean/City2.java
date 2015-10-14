package cn.bmob.zuqiuj.bean;

import java.util.ArrayList;

/**
 * Created by BaiKing Rio on 2015/1/27.
 */
public class City2 {
    // 市
    private ArrayList<Area> sub;
    private int key;
    private String value;

    public ArrayList<Area> getSub() {
        return sub;
    }

    public void setSub(ArrayList<Area> sub) {
        this.sub = sub;
    }

    public int getKey() {
        return key;
    }

    public void setKey(int key) {
        this.key = key;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
