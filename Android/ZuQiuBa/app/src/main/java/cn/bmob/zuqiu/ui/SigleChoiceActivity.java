package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.ListView;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;

public class SigleChoiceActivity extends BaseActivity{

	private ListView listview;
	private String[] legs = {"左脚","右脚","左右开弓"};
	private String[] location = {"门将","后卫","中场","前锋"};
	private SingleAdapter mAdapter;
	private int index;
	private String intentType ;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_sigle_choice);
		
		intentType = getIntent().getStringExtra("data");
		if(intentType!=null){
			if(intentType.equals("location")){
                setUpAction(mActionBarTitle, "场上位置", 0, View.VISIBLE);
			}else if(intentType.equals("goodat")){
                setUpAction(mActionBarTitle, "擅长脚", 0, View.VISIBLE);
			}
		}
		
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
	
		mAdapter = new SingleAdapter(this,getFillData(intentType));
		listview.setAdapter(mAdapter); 
		listview.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				mAdapter.setSelectedItem(position);
				mAdapter.notifyDataSetChanged();
				index = position;
			}
		});
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		listview = (ListView)contentView.findViewById(R.id.list_view);
	}
	
	private String[] getFillData(String intentType){
		if(intentType.equals("location")){
			return location;
		}else if(intentType.endsWith("goodat")){
			return legs;
		}
		return legs;
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
	
	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
		setResult(Activity.RESULT_OK, getIntent().putExtra("result", index+1));
		finish();
	}
	
	class SingleAdapter extends BaseAdapter{

		private Context mContext;
		private String[] titles;
		private List<Boolean> checkStatus = new ArrayList<Boolean>();
		private int selectedItem;
		
		public SingleAdapter(Context mContext, String[] titles) {
			super();
			this.mContext = mContext;
			this.titles = titles;
			for(int i=0;i<titles.length;i++){
				checkStatus.add(false);
			}
		}

		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			return titles.length;
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			return titles[position];
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			// TODO Auto-generated method stub
			ViewHolder viewHolder = null;
			if(convertView == null){
				viewHolder = new ViewHolder();
				convertView = ((LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.list_single_choice, null);
				viewHolder.title = (TextView)convertView.findViewById(R.id.item_title);
				viewHolder.checkBox = (CheckBox)convertView.findViewById(R.id.item_check);
				convertView.setTag(viewHolder);
			}else{
				viewHolder = (ViewHolder) convertView.getTag();
			}
			viewHolder.title.setText(titles[position]);
			if(selectedItem == position){
				viewHolder.checkBox.setChecked(true);
			}else{
				viewHolder.checkBox.setChecked(false);
			}
			return convertView;
		}
		
		public void setSelectedItem(int positioin){
			selectedItem = positioin;
		}
		
		class ViewHolder{
			TextView title;
			CheckBox checkBox;
		}
	}

}
