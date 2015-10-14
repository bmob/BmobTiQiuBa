package cn.bmob.zuqiu.view.views;

import cn.bmob.zuqiu.R;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.CheckBox;
import android.widget.Checkable;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class SigleCheckItem extends RelativeLayout implements Checkable {

	private CheckBox checkBox;
	private TextView title;
	private boolean checked;
	private static final int[] CheckedStateSet = { android.R.attr.state_checked };

	public SigleCheckItem(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
	}

	public SigleCheckItem(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	public SigleCheckItem(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		LayoutInflater inflator = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		inflator.inflate(R.layout.list_single_choice, this);
		checkBox = (CheckBox) findViewById(R.id.item_check);
		title = (TextView)findViewById(R.id.item_title);
	}

	public void setTitle(String string){
		title.setText(string);
	}
	
	@Override
	public void setChecked(boolean checked) {
		// TODO Auto-generated method stub
		this.checked = checked;
		if (checked) {
			checkBox.setChecked(checked);
		}else{
			checkBox.setChecked(!checked);
		}
		refreshDrawableState();
	}

	@Override
	public boolean isChecked() {
		// TODO Auto-generated method stub
		return checked;
	}

	@Override
	public void toggle() {
		// TODO Auto-generated method stub
		setChecked(!checked);
		checkBox.setChecked(!checked);
	}

	@Override
	protected int[] onCreateDrawableState(int extraSpace) {
		final int[] drawableState = super.onCreateDrawableState(extraSpace + 1);
		if (isChecked()) {
			mergeDrawableStates(drawableState, CheckedStateSet);
		}
		return drawableState;
	}

	@Override
	public boolean performClick() {
		toggle();
		return super.performClick();
	}
}
