package cn.bmob.zuqiuj.bean;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by BaiKing Rio on 2015/1/27.
 */
public class Area {
    // 区
    private ArrayList<Core> sub;
    private int key;
    private String value;

    public ArrayList<Core> getSub() {
        return sub;
    }

    public void setSub(ArrayList<Core> sub) {
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

    public ArrayList<String> getNames(){
        ArrayList<String> names = new ArrayList<String>();
        for (Core city : sub){
            names.add(city.getValue());
        }
        return names;
    }
}
