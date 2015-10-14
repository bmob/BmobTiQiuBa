package cn.bmob.zuqiu.ui;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.http.util.EncodingUtils;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.view.sortlistview.CharacterParser;
import cn.bmob.zuqiu.view.sortlistview.ClearEditText;
import cn.bmob.zuqiu.view.sortlistview.PinyinComparator;
import cn.bmob.zuqiu.view.sortlistview.SideBar;
import cn.bmob.zuqiu.view.sortlistview.SideBar.OnTouchingLetterChangedListener;
import cn.bmob.zuqiu.view.sortlistview.SortAdapter;
import cn.bmob.zuqiuj.bean.Area;
import cn.bmob.zuqiuj.bean.City;
import cn.bmob.zuqiuj.bean.City2;
import cn.bmob.zuqiuj.bean.Citys;
import cn.bmob.zuqiuj.bean.Citys2;
import cn.bmob.zuqiuj.bean.Core;

import com.alibaba.fastjson.JSONObject;

public class CityChooseActivity extends BaseActivity{
	private ListView sortListView;
	private SideBar sideBar;
	private TextView dialog;
	private SortAdapter adapter;
	private ClearEditText mClearEditText;
	/**
	 * 汉字转换成拼音的类
	 */
	private CharacterParser characterParser;
	/**
	 * 根据拼音来排列ListView里面的数据类
	 */
	private PinyinComparator pinyinComparator;
	List<City> city = new ArrayList<City>();
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_city_choose);
		setUpAction(mActionBarTitle, "选择城市", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		initViews();
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		sideBar = (SideBar) findViewById(R.id.sidrbar);
		dialog = (TextView) findViewById(R.id.dialog);
		sortListView = (ListView) findViewById(R.id.country_lvcountry);
		mClearEditText = (ClearEditText) findViewById(R.id.filter_edit);
	}
	
	
	private void initViews() {
		//实例化汉字转拼音类
		characterParser = CharacterParser.getInstance();
		
		pinyinComparator = new PinyinComparator();
		
		sideBar.setTextView(dialog);
		
		//设置右侧触摸监听
		sideBar.setOnTouchingLetterChangedListener(new OnTouchingLetterChangedListener() {
			
			@Override
			public void onTouchingLetterChanged(String s) {
				//该字母首次出现的位置
				int position = adapter.getPositionForSection(s.charAt(0));
				if(position != -1){
					sortListView.setSelection(position);
				}
				
			}
		});
		
		sortListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				//这里要利用adapter.getItem(position)来获取当前position所对应的对象
//				Toast.makeText(getApplication(), ((City)adapter.getItem(position)).getCityId(), Toast.LENGTH_SHORT).show();
				
				// 实例化 Bundle，设置需要传递的参数 
		        Bundle bundle = new Bundle(); 
		        bundle.putSerializable("city", (City)adapter.getItem(position));
		        setResult(RESULT_OK, CityChooseActivity.this.getIntent().putExtras(bundle)); 
		        CityChooseActivity.this.finish(); 
			}
		});
		
		String citystr = getFromRaw();
//        String citystr2 = getFromRawCity2();
		System.out.println(citystr);
//        System.out.println("citystr2 = "+citystr2);
		Citys citys = JSONObject.parseObject(citystr, Citys.class);
//        Citys2 citys2 = JSONObject.parseObject(citystr2, Citys2.class);
//        List<City2> city2s = JSONObject.parseArray(citystr2, City2.class);
		city = citys.getData();
        
//        for (City2 city : citys2.getSub()){
////            System.out.println("省: key="+citys2.getKey()+" value="+citys2.getValue());
//            for (Area area : city.getSub()){
//                System.out.println("市: key="+city.getKey()+" value="+city.getValue());
//                for (Core core : area.getSub()){
//                    System.out.println("区：key="+core.getKey()+" value="+core.getValue());
//                }
//            }
//        }
		
		// 根据a-z进行排序源数据
		Collections.sort(city, pinyinComparator);
		adapter = new SortAdapter(this, city);
		sortListView.setAdapter(adapter);
		
		
		//根据输入框输入值的改变来过滤搜索
		mClearEditText.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				//当输入框里面的值为空，更新为原来的列表，否则为过滤数据列表
				filterData(s.toString());
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				
			}
			
			@Override
			public void afterTextChanged(Editable s) {
			}
		});
	}
	
	/**
	 * 为ListView填充数据
	 * @param date
	 * @return
	 */
	private List<City> filledData(String [] date){
		List<City> mSortList = new ArrayList<City>();
		
		for(int i=0; i<date.length; i++){
			City sortModel = new City();
			sortModel.setCity_name(date[i]);
			//汉字转换成拼音
			String pinyin = characterParser.getSelling(date[i]);
			String sortString = pinyin.substring(0, 1).toUpperCase();
			
			// 正则表达式，判断首字母是否是英文字母
			if(sortString.matches("[A-Z]")){
				sortModel.setSortLetter(sortString.toUpperCase());
			}else{
				sortModel.setSortLetter("#");
			}
			
			mSortList.add(sortModel);
		}
		return mSortList;
		
	}
	
	/**
	 * 根据输入框中的值来过滤数据并更新ListView
	 * @param filterStr
	 */
	private void filterData(String filterStr){
		List<City> filterDateList = new ArrayList<City>();
		
		if(TextUtils.isEmpty(filterStr)){
			filterDateList = city;
		}else{
			filterDateList.clear();
			for(City sortModel : city){
				String name = sortModel.getCity_name();
				if(name.indexOf(filterStr.toString()) != -1 || characterParser.getSelling(name).startsWith(filterStr.toString())){
					filterDateList.add(sortModel);
				}
			}
		}
		
		// 根据a-z进行排序
		Collections.sort(filterDateList, pinyinComparator);
		adapter.updateListView(filterDateList);
	}
	
	public String getFromRaw(){   
	    String result = "";   
	        try {   
	            InputStream in = getResources().openRawResource(R.raw.city);   
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
	        return result;   
	}
    
    public String getFromRawCity2(){
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
        return result;
    }
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
}
