package cn.bmob.zuqiu.view.views;

import java.util.Calendar;

import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.view.views.NumberPicker.OnValueChangeListener;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.TextSwitcher;


public class TimePicker extends FrameLayout implements OnClickListener {

	private Context mContext;
	private NumberPicker hourPicker;
	private NumberPicker minPicker;
	private TextSwitcher timeSwitcher;

	private Calendar mCalendar;
	boolean is24Hour;
	boolean isAm = true;

	public TimePicker(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
		mCalendar = Calendar.getInstance();
		((LayoutInflater) mContext
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(
				R.layout.time_picker, this, true);
		hourPicker = (NumberPicker) findViewById(R.id.time_hours);
		minPicker = (NumberPicker) findViewById(R.id.time_minutes);
		timeSwitcher = (TextSwitcher) findViewById(R.id.time_switcher);

		minPicker.setMinValue(0);
		minPicker.setMaxValue(59);
		minPicker.setFormatter(NumberPicker.TWO_DIGIT_FORMATTER);
		hourPicker.setFormatter(NumberPicker.TWO_DIGIT_FORMATTER);

		is24Hour = android.text.format.DateFormat.is24HourFormat(context);

		timeSwitcher.setOnClickListener(this);
		minPicker.setOnValueChangedListener(new OnValueChangeListener() {

			@Override
			public void onValueChange(NumberPicker picker, int oldVal,
					int newVal) {
				mCalendar.set(Calendar.MINUTE, newVal);

			}
		});

		hourPicker.setOnValueChangedListener(new OnValueChangeListener() {

			@Override
			public void onValueChange(NumberPicker picker, int oldVal,
					int newVal) {
				mCalendar.set(Calendar.HOUR, newVal);
			}
		});

		updateTime();

	}

	public TimePicker(Context context) {
		this(context, null);
	}

	private void updateTime() {
		System.out.println(mCalendar.getTime());
		if (is24Hour) {

			hourPicker.setMinValue(0);
			hourPicker.setMaxValue(23);
			hourPicker.setValue(mCalendar.get(Calendar.HOUR_OF_DAY));
			timeSwitcher.setVisibility(View.GONE);
		} else {
			hourPicker.setMinValue(1);
			hourPicker.setMaxValue(12);
			hourPicker.setValue(mCalendar.get(Calendar.HOUR));
			if (mCalendar.get(Calendar.AM_PM) == Calendar.PM) {
				isAm = false;
				timeSwitcher.setText("pm");
			} else {
				isAm = true;
				timeSwitcher.setText("am");
			}

			timeSwitcher.setVisibility(View.VISIBLE);

		}
		minPicker.setValue(mCalendar.get(Calendar.MINUTE));
	}

	public boolean isIs24Hour() {
		return is24Hour;
	}

	public void setIs24Hour(boolean is24Hour) {
		this.is24Hour = is24Hour;
	}

	public String getTime() {
		String time = "";
		if (is24Hour) {
			time = hourPicker.getValue() + ":" + minPicker.getValue();
		} else {
			time = hourPicker.getValue() + ":" + minPicker.getValue() + " "
					+ (isAm ? "am" : "pm");

		}
		return time;
	}

	public int getHourOfDay() {
		return is24Hour || isAm ? hourPicker.getValue() : (hourPicker
				.getValue() + 12) % 24;
	}

	public int getHour() {
		return hourPicker.getValue();
	}

	public int getMinute() {
		return mCalendar.get(Calendar.MINUTE);
	}

	public void setCalendar(Calendar calendar) {
		this.mCalendar.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY));
		this.mCalendar.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE));
		updateTime();
	}

	@Override
	public void onClick(View v) {
		isAm = !isAm;

		if (isAm) {
			mCalendar.roll(Calendar.HOUR, -12);
			timeSwitcher.setText("am");
		} else {
			mCalendar.roll(Calendar.HOUR, 12);
			timeSwitcher.setText("pm");
		}

	}

}
