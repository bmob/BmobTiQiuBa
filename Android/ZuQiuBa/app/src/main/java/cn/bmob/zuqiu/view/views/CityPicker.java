package cn.bmob.zuqiu.view.views;

import android.text.TextUtils;
import android.widget.LinearLayout;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;

import com.alibaba.fastjson.JSONObject;

import org.apache.http.util.EncodingUtils;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import cn.bmob.zuqiu.R;
import cn.bmob.zuqiuj.bean.Area;
import cn.bmob.zuqiuj.bean.City2;
import cn.bmob.zuqiuj.bean.Citys2;
import cn.bmob.zuqiuj.bean.Core;

/**
 * Created by BaiKing Rio on 2015/1/27.
 */
public class CityPicker extends LinearLayout {
    /** 滑动控件 */
    private ScrollerNumberPicker provincePicker;
    private ScrollerNumberPicker cityPicker;
    private ScrollerNumberPicker counyPicker;
    /** 选择监听 */
    private OnSelectingListener onSelectingListener;
    /** 刷新界面 */
    private static final int REFRESH_VIEW = 0x001;
    /** 临时索引 主要解决第一次重复触发的问题 */
    // 如:第一个选择了县,并且改变了值, 这时如果在选择市,即使不改变值,只要触发,县就会初始化,此处就是解决这个问题的
    private int tempProvinceIndex = -1;
    private int temCityIndex = -1;
    private int tempCounyIndex = -1;
    /** 上下文 */
    private Context context;
    /** 省的集合 */
    private ArrayList<String> province_list = new ArrayList<String>();
//    private Citys2 province_list = new Citys2();
    /** 市的集合 */
    private HashMap<String, ArrayList<String>> city_map = new HashMap<String, ArrayList<String>>();
//    private HashMap<String, ArrayList<Area>> city_map = new HashMap<String, ArrayList<Area>>();
    /** 县的集合 */
//    private HashMap<String, ArrayList<Cityinfo>> couny_map = new HashMap<String, ArrayList<Cityinfo>>();
    private HashMap<String, ArrayList<Core>> couny_map = new HashMap<String, ArrayList<Core>>();
    /** 数据初始化的对象 */
//    private JSONParser parser;
    /** 当前选中的省、市、县、及县代码的索引 */
    private String province_name = "北京";
    private String city_name = "北京市";
    private String county_name = "北京";
    private String county_code = "101010100";   // 县的代码
    private String city_code = "";  // 市的代码
    
    // 所有市的名称、代码集合
    private HashMap<String, Integer> allCity = new HashMap<String, Integer>();

    private String city_string;

    public CityPicker(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
        getaddressinfo();

    }

    public CityPicker(Context context) {
        super(context);
        this.context = context;
        getaddressinfo();

    }

    /** 获取城市信息 */
    private void getaddressinfo() {

        // 读取文件里的城市信息
        String area_str = getFromRaw();
        // 解析城市信息
//        parser = new JSONParser();
//        province_list = parser.getJSONParserResult(area_str, "area0");
//        city_map = parser.getJSONParserResultArray(area_str, "area1");
//        couny_map = parser.getJSONParserResultArray2(area_str, "area2");
        
        Citys2 citys2 = JSONObject.parseObject(area_str, Citys2.class);
//        province_list = JSONObject.parseObject(area_str, Citys2.class);
        parseShen(citys2);
//        province_list = citys2.getSub();
//        city_map = citys2.getSub().get()
    }
    
    private void parseShen(Citys2 citys2){
//        HashMap<String, ArrayList<String>> hashMap = new HashMap<String, ArrayList<String>>();
//        ArrayList<String> list = new ArrayList<String>();
//        for (City2 city : citys2.getSub()){
//            province_list.add(city.getValue());
////            System.out.println("市: key="+city.getKey()+" value="+city.getValue());
//            ArrayList<String> shi = new ArrayList<String>();
//            for (Area area : city.getSub()){
////                System.out.println("市: key="+area.getKey()+" value="+area.getValue());
//                shi.add(city.getValue());
//                
//                for (Core core : area.getSub()){
////                    couny_map.put(core.getValue(), core.getNames());
////                    System.out.println("区：key="+core.getKey()+" value="+core.getValue());
//                }
//            }
//            city_map.put(city.getValue(), shi);
//        }
////        province_list = list;
//        System.out.println("province_list ="+province_list.size());
//        System.out.println("city_map ="+city_map.size());
////        for (String key :city_map.keySet()){
////            System.out.println("key ="+key);
////            city_map.get("湖南省");
//            for (String s :city_map.get("湖南省")){
//                System.out.println("s ="+s);
//            }
//        }
        
        for (City2 province : citys2.getSub()){
            // 所有的省
            province_list.add(province.getValue());
            ArrayList<String> shiList = new ArrayList<String>();
            for (Area shi : province.getSub()){
                // xx省的所有市
                shiList.add(shi.getValue());
                allCity.put(shi.getValue(),shi.getKey());
//                ArrayList<Core> xianList = new ArrayList<Core>();
//                for (Core xian : shi.getSub()){
//                    // xx市的所有县或区
//                    xianList.add(xian.getValue());
//                }
                // xx市的所有县或区
                couny_map.put(shi.getValue(), shi.getSub());
            }
            city_map.put(province.getValue(), shiList);
        }
        System.out.println("province_list ="+province_list.size());
        System.out.println("city_map ="+city_map.size());

//        for (Core s :couny_map.get("常德市")){
//                System.out.println("x ="+s.getValue());
//            }
        
        
        
        
        
        
        
        
        
    }

    public String getFromRaw(){
        String result = "";
        try {
            InputStream in = getResources().openRawResource(R.raw.city2);
            //获取文件的字节数   
            int lenght = in.available();
            //创建byte数组   
            byte[]  buffer = new byte[lenght];
            //将文件中的数据读到byte数组中   
            in.read(buffer);
            result = EncodingUtils.getString(buffer, "utf-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("result = "+result);
        return result;
    }
    
    private ArrayList<String> myToArrayList(List<Core> cores){
        ArrayList<String> xianList = new ArrayList<String>();
        for (Core core : cores){
            xianList.add(core.getValue());
        }
        return xianList;
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        LayoutInflater.from(getContext()).inflate(R.layout.city_picker, this);

        // 获取控件引用
        provincePicker = (ScrollerNumberPicker) findViewById(R.id.province);
        cityPicker = (ScrollerNumberPicker) findViewById(R.id.city);
        counyPicker = (ScrollerNumberPicker) findViewById(R.id.couny);

        provincePicker.setData(province_list);
        cityPicker.setData(city_map.get("北京市"));
        counyPicker.setData(myToArrayList(couny_map.get("北京市")));

        provincePicker.setDefault(0);
        cityPicker.setDefault(0);
        counyPicker.setDefault(0);
        // 设置省控件的监听器
        provincePicker.setOnSelectListener(new ScrollerNumberPicker.OnSelectListener() {

            @Override
            public void endSelect(int id, String text) {
                if(TextUtils.isEmpty(text)){
                    return;
                }
                if (tempProvinceIndex != id) {
                    String selectDay = cityPicker.getSelectedText();
                    if (selectDay == null || selectDay.equals("")) {
                        return;
                    }
                    String selectMonth = counyPicker.getSelectedText();
                    if (selectMonth == null || selectMonth.equals("")) {
                        return;
                    }
                    if (temCityIndex < 0) {
                        temCityIndex = 0;
                    }
                    if (tempCounyIndex < 0) {
                        tempCounyIndex = 0;
                    }

                    // 更改省的名称
                    province_name = text;

                    // 设置市的数据内容
                    cityPicker.setData(city_map.get(text));
                    cityPicker.setDefault(0);
                    city_name = cityPicker.getSelectedText();
                    // 设置县的数据内容
                    counyPicker.setData(myToArrayList(couny_map
                            .get(cityPicker.getSelectedText())));
//                    counyPicker.setData(city_map.get(cityPicker.getSelectedText()));
                    counyPicker.setDefault(0);
                    county_name = counyPicker.getSelectedText();
                    county_code = couny_map.get(city_name).get(0).getKey()+"";

                }
                tempProvinceIndex = id;
                Message message = new Message();
                message.what = REFRESH_VIEW;
                handler.sendMessage(message);
            }

            @Override
            public void selecting(int id, String text) {
            }
        });
        // 设置市控件的监听器
        cityPicker.setOnSelectListener(new ScrollerNumberPicker.OnSelectListener() {

            @Override
            public void endSelect(int id, String text) {
                if(TextUtils.isEmpty(text)){
                    return;
                }
                if (temCityIndex != id) {
                    String selectDay = provincePicker.getSelectedText();
                    if (selectDay == null || selectDay.equals("")) {
                        return;
                    }
                    String selectMonth = counyPicker.getSelectedText();
                    if (selectMonth == null || selectMonth.equals("")) {
                        return;
                    }
                    if (tempCounyIndex < 0) {
                        tempCounyIndex = 0;
                    }
                    if (tempProvinceIndex < 0) {
                        tempProvinceIndex = 0;
                    }
                    city_name = text;
                    // 设置县的数据内容
                    counyPicker.setData(myToArrayList(couny_map.get(text)));
                    counyPicker.setDefault(0);

                    county_name = counyPicker.getSelectedText();
                    county_code = couny_map.get(city_name).get(0).getKey()+"";

                }
                temCityIndex = id;
                Message message = new Message();
                message.what = REFRESH_VIEW;
                handler.sendMessage(message);
            }

            @Override
            public void selecting(int id, String text) {

            }
        });
        // 设置县控件的监听器
        counyPicker.setOnSelectListener(new ScrollerNumberPicker.OnSelectListener() {

            @Override
            public void endSelect(int id, String text) {
                if(TextUtils.isEmpty(text)){
                    return;
                }
                if (tempCounyIndex != id) {
                    String selectDay = provincePicker.getSelectedText();
                    if (selectDay == null || selectDay.equals("")) {
                        return;
                    }
                    String selectMonth = cityPicker.getSelectedText();
                    if (selectMonth == null || selectMonth.equals("")) {
                        return;
                    }
                    if (temCityIndex < 0) {
                        temCityIndex = 0;
                    }
                    if (tempProvinceIndex < 0) {
                        tempProvinceIndex = 0;
                    }

                    // 改变县的名称
                    county_name = text;
                    // 在县集合中得到城市的天气代码
                    county_code = couny_map.get(city_name).get(id).getKey()+"";

                }
                tempCounyIndex = id;
                Message message = new Message();
                message.what = REFRESH_VIEW;
                handler.sendMessage(message);
            }

            @Override
            public void selecting(int id, String text) {

            }
        });
    }

    // 这是用来更新界面，和绑定监听器值的
    @SuppressLint("HandlerLeak")
    Handler handler = new Handler() {

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case REFRESH_VIEW:
                    if (onSelectingListener != null)
                        onSelectingListener.selected(true, province_name,
                                city_name, county_name, county_code);
                    break;
                default:
                    break;
            }
        }

    };

    /**
     * 绑定监听器
     *
     * @param onSelectingListener
     *            控件的监听器接口
     */
    public void setOnSelectingListener(OnSelectingListener onSelectingListener) {
        this.onSelectingListener = onSelectingListener;
    }

    /**
     * 得到所选择的省的名称
     *
     * @return 省的名称
     */
    public String getprovince_name() {
        return province_name;
    }

    /**
     * 得到所选择的市的名称
     *
     * @return 市的名称
     */
    public String getcity_name() {
        return city_name;
    }

    /**
     * 得到所选择的市的代码
     * @return
     */
    public String getCity_code(){
        return allCity.get(getcity_name())+"";
    }

    /**
     * 得到所选择的县的名称
     *
     * @return 省县的名称
     */
    public String getcouny_name() {
        return county_name;
    }

    /**
     * 得到所选择的城市的的天气查询代码
     *
     * @return 城市的的天气查询代码
     */
    public String getCounty_code() {
        return county_code;
    }

    /**
     * 得到所选择的省--市--县
     *
     * @return省--市--县
     */
    public String getCity_string() {
//        city_string = provincePicker.getSelectedText() + "--"
//                + cityPicker.getSelectedText() + "--"
//                + counyPicker.getSelectedText();
        city_string = provincePicker.getSelectedText()
                + cityPicker.getSelectedText()
                + counyPicker.getSelectedText();
        return city_string;
    }

    /**
     * 监听器接口
     *
     * @author LOVE
     *
     */
    public interface OnSelectingListener {

        /**
         * @param selected
         *            是否选择该控件？？？
         * @param province_name
         *            省的名称
         * @param city_name
         *            市的名称
         * @param couny_name
         *            县的名称
         * @param city_code
         *            城市天气代码
         */
        public void selected(boolean selected, String province_name,
                             String city_name, String couny_name, String city_code);
    }
}
