package cn.bmob.zuqiu.ui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.util.Calendar;
import java.util.Date;

import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.view.views.CityPicker;
import cn.bmob.zuqiu.view.views.DatePicker;
import cn.bmob.zuqiu.view.views.TimePicker;
import cn.bmob.zuqiuj.bean.User;

/**
 * 创建比赛
 */
public class CreateCompetitionActivity extends BaseActivity{

	EditText cpDate;
	EditText cpPeriod;
	EditText cpSite;
    EditText cpCity;
	Button cpNext;
	
	private BmobDate date;
	private BmobDate begin;
	private BmobDate end;
	private String site;
    private String cityCode;
	private Date comDate;
	
	private User user;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_create_competition);
		setUpAction(mActionBarTitle, "添加比赛记录", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		user = BmobUser.getCurrentUser(mContext, User.class);
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		cpDate = (EditText)contentView.findViewById(R.id.cp_date_content);
		cpPeriod = (EditText)contentView.findViewById(R.id.cp_period_content);
		cpSite = (EditText)contentView.findViewById(R.id.cp_site_content);
        cpCity = (EditText) contentView.findViewById(R.id.cp_city_content);
		cpNext = (Button)contentView.findViewById(R.id.cp_create_next);
		
		cpDate.setInputType(InputType.TYPE_NULL); 
		cpPeriod.setInputType(InputType.TYPE_NULL); 
		cpCity.setInputType(InputType.TYPE_NULL);
		
		cpDate.setOnClickListener(this);
		cpPeriod.setOnClickListener(this);
		cpSite.setOnClickListener(this);
        cpCity.setOnClickListener(this);
		cpNext.setOnClickListener(this);
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.cp_date_content:
			showTimeDialog(mContext,getDateView());
			
			break;
		case R.id.cp_period_content:
			if(date==null){
				showToast("请先设置比赛日期");
				return;
			}
			showTimeDialog(mContext, getBeginView());
			break;
		case R.id.cp_site_content:
			
			break;
        case R.id.cp_city_content:
            showSelectCityDialog();
            break;
		case R.id.cp_create_next:
			if(null==date){
				showToast("请选择比赛日期");
				return;
			}
			
			if(null==begin){
				showToast("请选择比赛开始时间");
				return;
			}
			
//			if(null==end){
//				showToast("请选择比赛结束日期。");
//				return;
//			}
			
			site = cpSite.getText().toString().trim();
			if(TextUtils.isEmpty(site)){
				showToast("请输入地点");
				return;
			}
            
            if(TextUtils.isEmpty(cityCode)){
                showToast("请输选择城市");
                return;
            }
			
			MyApplication.getInstance().getmTournament().setEvent_date(date);//比赛日期
			MyApplication.getInstance().getmTournament().setStart_time(begin);//比赛时间
			MyApplication.getInstance().getmTournament().setCity(cityCode);//比赛城市
			MyApplication.getInstance().getmTournament().setSite(site);//比赛地点
			MyApplication.getInstance().getmTournament().setState(false);
			
			redictTo(mContext, ChooseHomeTeamActivity.class, null);
			break;
		default:
			break;
		}
	}

    /**
     * 打开城市选择对话框
     */
    private void showSelectCityDialog(){
        final Dialog timeDialog = new AlertDialog.Builder(this).create();
        View view = LayoutInflater.from(this).inflate(
                R.layout.dialog_city_picker, null);

        timeDialog.setCanceledOnTouchOutside(true);
        timeDialog.show();
        timeDialog.setContentView(view);
        final CityPicker cityPicker = (CityPicker) view.findViewById(R.id.cityPicker);
        view.findViewById(R.id.date_commit).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
//                showToast("您选择的城市是："+cityPicker.getCity_string()+cityPicker.getcity_name()+"----"+cityPicker.getCounty_code()+"  市代码："+cityPicker.getCity_code());
                cpCity.setText(cityPicker.getCity_string());
                cityCode = cityPicker.getCity_code();
                timeDialog.cancel();
            }
        });
        view.findViewById(R.id.btn_cancel).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                timeDialog.cancel();
            }
        });
    }
	
	Dialog timeDialog = null;
	private void showTimeDialog(Context context,View view){
		if(timeDialog == null){
			timeDialog = new AlertDialog.Builder(context).create();
		}
		timeDialog.show();
		timeDialog.setCanceledOnTouchOutside(false);
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.CENTER);
		timeDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth()-30,
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
	}

	/**
	 * 处理日期选择
	 * @return
	 */
	private View getDateView() {
		View view = LayoutInflater.from(CreateCompetitionActivity.this).inflate(
				R.layout.dialog_date_picker, null);
		TextView title = (TextView)view.findViewById(R.id.picker_title);
		title.setText("选择日期");
		final DatePicker datePicker = (DatePicker)view.findViewById(R.id.datePicker);
		datePicker.setYearMin(Integer.parseInt(TimeUtils.getCurrentYear()));
		Button commit = (Button)view.findViewById(R.id.date_commit);
		commit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Calendar mCalendar = Calendar.getInstance();
				mCalendar.set(Calendar.YEAR, datePicker.getYear());
				mCalendar.set(Calendar.MONTH, datePicker.getMonth());
				mCalendar.set(Calendar.DAY_OF_MONTH, datePicker.getDay());
				mCalendar.set(Calendar.HOUR_OF_DAY, 0);
				mCalendar.set(Calendar.MINUTE,0);
				mCalendar.set(Calendar.SECOND, 0);
				comDate = mCalendar.getTime();
				date = new BmobDate(mCalendar.getTime());
				cpDate.setText(getStringByDate(date));
//				birthContent.setText(new BmobDate(mCalendar.getTime()).getDate().substring(0, 10));
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
		return view;
	}
	
	
	private boolean isSecond = false;
	/**
	 * 处理日期选择
	 * @return
	 */
	private View getBeginView() {
		View view = LayoutInflater.from(CreateCompetitionActivity.this).inflate(
				R.layout.dialog_time_picker, null);
		final TextView title = (TextView)view.findViewById(R.id.picker_title);
		title.setText("选择开始时间");
		final TimePicker timePicker = (TimePicker)view.findViewById(R.id.timePicker);
		timePicker.setIs24Hour(true);
		Button commit = (Button)view.findViewById(R.id.time_commit);
		commit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Calendar mCalendar = Calendar.getInstance();
				mCalendar.setTime(comDate);
//				mCalendar.set(Calendar.YEAR, getCalendarByDate(comDate).get(Calendar.YEAR));
//				mCalendar.set(Calendar.MONTH, getCalendarByDate(comDate).get(Calendar.MONTH));
//				mCalendar.set(Calendar.DAY_OF_MONTH, getCalendarByDate(comDate).get(Calendar.DAY_OF_YEAR));
				mCalendar.set(Calendar.HOUR_OF_DAY, timePicker.getHour());
				mCalendar.set(Calendar.MINUTE,timePicker.getMinute());
				mCalendar.set(Calendar.SECOND, 0);
//				if(isSecond){
//					end = new BmobDate(mCalendar.getTime());
//					cpPeriod.setText(cpPeriod.getText()+getTimeByDate(end));
//					isSecond = false;
//					if(timeDialog!=null&&timeDialog.isShowing()){
//						timeDialog.dismiss();
//					}
//				}else{
					
//					Calendar mCalendar2 = Calendar.getInstance();
//					mCalendar2.setTime(new Date());
//					if(mCalendar2.getTimeInMillis()-mCalendar.getTimeInMillis()>0){
//						showToast("您不能选择以前的时间。请重新选择");
//						return;
//					}else{
						begin = new BmobDate(mCalendar.getTime());
						cpPeriod.setText(getTimeByDate(begin));//+" 至 ");
						if(timeDialog!=null&&timeDialog.isShowing()){
							timeDialog.dismiss();
						}
//					}

//					isSecond = true;
//					if(isSecond){
//						title.setText("选择结束时间");
//						showToast("选择结束时间");
//					}
//					
//				}
//				birthContent.setText(new BmobDate(mCalendar.getTime()).getDate().substring(0, 10));
//				if(timeDialog!=null&&timeDialog.isShowing()){
//					timeDialog.dismiss();
//				}
				
//				showTimeDialog(mContext, getEndView());
			}
		});
		return view;
	}
	
	/**
	 * 处理日期选择
	 * @return
	 */
	private View getEndView() {
		View view = LayoutInflater.from(CreateCompetitionActivity.this).inflate(
				R.layout.dialog_time_picker, null);
		TextView title = (TextView)view.findViewById(R.id.picker_title);
		title.setText("选择结束时间");
		final TimePicker timePicker = (TimePicker)view.findViewById(R.id.timePicker);
		timePicker.setIs24Hour(true);
		Button commit = (Button)view.findViewById(R.id.time_commit);
		commit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Calendar mCalendar = Calendar.getInstance();
				mCalendar.setTime(comDate);
//				mCalendar.set(Calendar.YEAR, getCalendarByDate(comDate).get(Calendar.YEAR));
//				mCalendar.set(Calendar.MONTH, getCalendarByDate(comDate).get(Calendar.MONTH));
//				mCalendar.set(Calendar.DAY_OF_MONTH, getCalendarByDate(comDate).get(Calendar.DAY_OF_YEAR));
				mCalendar.set(Calendar.HOUR_OF_DAY, timePicker.getHour());
				mCalendar.set(Calendar.MINUTE,timePicker.getMinute());
				mCalendar.set(Calendar.SECOND, 0);
				end = new BmobDate(mCalendar.getTime());
				cpPeriod.setText(cpPeriod.getText()+getTimeByDate(end));
//				birthContent.setText(new BmobDate(mCalendar.getTime()).getDate().substring(0, 10));
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
		return view;
	}
	
	
	/*
	 * 根据用户选择的日期生成相应的文字
	 */
	private String getStringByDate(BmobDate date){
		String time = date.getDate();
		return time.substring(0, 4)+"年"+time.substring(5,7)+"月"+time.substring(8,10)+"日";
	}
	
	private String getTimeByDate(BmobDate date){
		String time = date.getDate();
		return time.substring(11, 16);
	}
	
	private Calendar getCalendarByDate(Date date){
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar;
	}
}
