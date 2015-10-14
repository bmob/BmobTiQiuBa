package cn.bmob.zuqiu.view.views;

import java.util.Calendar;

import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.view.views.NumberPicker.OnValueChangeListener;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;


public class DatePicker extends FrameLayout {

	private Context mContext;
	private NumberPicker mDayPicker;
	private NumberPicker mMonthPicker;
	private NumberPicker mYearPicker;
	private Calendar mCalendar;

	private String[] mMonthDisplay;

	public DatePicker(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
		mCalendar = Calendar.getInstance();
		initMonthDisplay();
		((LayoutInflater) mContext
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(
				R.layout.date_picker, this, true);
		mDayPicker = (NumberPicker) findViewById(R.id.date_day);
		mMonthPicker = (NumberPicker) findViewById(R.id.date_month);
		mYearPicker = (NumberPicker) findViewById(R.id.date_year);

		mDayPicker.setMinValue(1);
		mDayPicker.setMaxValue(31);
		mDayPicker.setValue(20);
		mDayPicker.setFormatter(NumberPicker.TWO_DIGIT_FORMATTER);

		mMonthPicker.setMinValue(0);
		mMonthPicker.setMaxValue(11);
		mMonthPicker.setDisplayedValues(mMonthDisplay);
		mMonthPicker.setValue(mCalendar.get(Calendar.MONTH));

		mYearPicker.setMinValue(1950);
		mYearPicker.setMaxValue(2100);
		mYearPicker.setValue(mCalendar.get(Calendar.YEAR));

		mMonthPicker.setOnValueChangedListener(new OnValueChangeListener() {

			@Override
			public void onValueChange(NumberPicker picker, int oldVal,
					int newVal) {
				mCalendar.set(Calendar.MONTH, newVal);
				updateDate();
			}
		});
		mDayPicker.setOnValueChangedListener(new OnValueChangeListener() {

			@Override
			public void onValueChange(NumberPicker picker, int oldVal,
					int newVal) {

				mCalendar.set(Calendar.DATE, newVal);
				updateDate();
			}
		});
		mYearPicker.setOnValueChangedListener(new OnValueChangeListener() {

			@Override
			public void onValueChange(NumberPicker picker, int oldVal,
					int newVal) {
				mCalendar.set(Calendar.YEAR, newVal);
				updateDate();

			}
		});

		updateDate();

	}
	
	public void setYearMin(int min){
		mYearPicker.setMinValue(min);
	}
    
    public void setDefaultYear(int year){
        mYearPicker.setValue(year);
    }

	private void initMonthDisplay() {
		mMonthDisplay = new String[12];
		mMonthDisplay[0] = "01";
		mMonthDisplay[1] = "02";
		mMonthDisplay[2] = "03";
		mMonthDisplay[3] = "04";
		mMonthDisplay[4] = "05";
		mMonthDisplay[5] = "06";
		mMonthDisplay[6] = "07";
		mMonthDisplay[7] = "08";
		mMonthDisplay[8] = "09";
		mMonthDisplay[9] = "10";
		mMonthDisplay[10] = "11";
		mMonthDisplay[11] = "12";
	}

	private void updateDate() {
		System.out.println("Month: " + mCalendar.get(Calendar.MONTH) + " Max: "
				+ mCalendar.getActualMaximum(Calendar.DATE));
		mDayPicker.setMinValue(mCalendar.getActualMinimum(Calendar.DATE));
		mDayPicker.setMaxValue(mCalendar.getActualMaximum(Calendar.DATE));
		mDayPicker.setValue(mCalendar.get(Calendar.DATE));
		mMonthPicker.setValue(mCalendar.get(Calendar.MONTH));
		mYearPicker.setValue(mCalendar.get(Calendar.YEAR));
        
	}

	public DatePicker(Context context) {
		this(context, null);
	}

	public String getDate() {
		String date = mYearPicker.getValue() + "-"
				+ (mMonthPicker.getValue() + 1) + "-" + mDayPicker.getValue();
		return date;

	}

	public int getDay() {
		return mCalendar.get(Calendar.DAY_OF_MONTH);
	}

	public int getMonth() {
		return mCalendar.get(Calendar.MONTH);
	}

	public int getYear() {
		return mCalendar.get(Calendar.YEAR);
	}

	public void setCalendar(Calendar calendar) {
		mCalendar = calendar;
		updateDate();
	}

}
