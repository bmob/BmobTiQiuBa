package cn.bmob.zuqiu.ui;

import android.os.Bundle;
import android.renderscript.Program.TextureType;
import android.text.Editable;
import android.text.InputType;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;

public class ModifyItemActivity extends BaseActivity{

	private TextView inputTips, mHintTextView;
	private EditText mInputEditText;
	private int modify_type = 1;

    private int MAX_COUNT = 8; // 昵称长度8个汉字
    private TextWatcher mTextWatcher = new TextWatcher() {

        private int editStart;

        private int editEnd;

        public void afterTextChanged(Editable s) {
            editStart = mInputEditText.getSelectionStart();
            editEnd = mInputEditText.getSelectionEnd();

            // 先去掉监听器，否则会出现栈溢出  
            mInputEditText.removeTextChangedListener(mTextWatcher);

            // 注意这里只能每次都对整个EditText的内容求长度，不能对删除的单个字符求长度  
            // 因为是中英文混合，单个字符而言，calculateLength函数都会返回1  
            while (calculateLength(s.toString()) > MAX_COUNT) { // 当输入字符个数超过限制的大小时，进行截断操作  
                s.delete(editStart - 1, editEnd);
                editStart--;
                editEnd--;
            }
            // mEditText.setText(s);将这行代码注释掉就不会出现后面所说的输入法在数字界面自动跳转回主界面的问题了，多谢@ainiyidiandian的提醒  
            mInputEditText.setSelection(editStart);

            // 恢复监听器  
            mInputEditText.addTextChangedListener(mTextWatcher);

            setLeftCount();
        }

        public void beforeTextChanged(CharSequence s, int start, int count,
                                      int after) {

        }

        public void onTextChanged(CharSequence s, int start, int before,
                                  int count) {

        }
    };

    /**
     * 刷新剩余输入字数,最大值新浪微博是140个字，人人网是200个字 
     */
    private void setLeftCount() {
        mHintTextView.setText(String.valueOf((MAX_COUNT - getInputCount())));
    }

    /**
     * 获取用户输入的分享内容字数 
     *
     * @return
     */
    private long getInputCount() {
        return calculateLength(mInputEditText.getText().toString());
    }

    /**
     * 计算分享内容的字数，一个汉字=两个英文字母，一个中文标点=两个英文标点 注意：该函数的不适用于对单个字符进行计算，因为单个字符四舍五入后都是1 
     *
     * @param c
     * @return
     */
    private long calculateLength(CharSequence c) {
        double len = 0;
        for (int i = 0; i < c.length(); i++) {
            int tmp = (int) c.charAt(i);
            if (tmp > 0 && tmp < 127) {
                len += 0.5;
            } else {
                len++;
            }
        }
        return Math.round(len);
    }
    
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_modify_item);
		modify_type = getIntent().getIntExtra("modify_type", 1);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarTitle, "修改信息", 0, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
	
		switch (modify_type) {
		case 1:
			setUpAction(mActionBarTitle, "修改昵称", 0, View.VISIBLE);
			inputTips.setText("昵称");
            mInputEditText.setHint("请输入昵称...");
            mInputEditText.addTextChangedListener(mTextWatcher);
            mHintTextView.setText(MAX_COUNT+"");
            mHintTextView.setVisibility(View.VISIBLE);
			break;
		case 2:
            mInputEditText.setInputType(InputType.TYPE_CLASS_NUMBER);
			setUpAction(mActionBarTitle, "修改体重", 0, View.VISIBLE);
			inputTips.setText("体重(kg)");
            mInputEditText.setHint("请输入体重...");
			break;
		case 3:
            mInputEditText.setInputType(InputType.TYPE_CLASS_NUMBER);
			setUpAction(mActionBarTitle, "修改身高", 0, View.VISIBLE);
			inputTips.setText("身高(cm)");
            mInputEditText.setHint("请输入身高...");
			break;
		}
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		inputTips = (TextView)contentView.findViewById(R.id.modify_input_tips);
        mInputEditText = (EditText)contentView.findViewById(R.id.modify_input_content);
		mHintTextView = (TextView) contentView.findViewById(R.id.tv_hint);
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
		String input = mInputEditText.getText().toString().trim();
		if(TextUtils.isEmpty(input)){
			showToast("输入内容不能为空...");
			return;
		}
		Bundle bundle = new Bundle();
		bundle.putString("content", input);
		setResult(RESULT_OK, getIntent().putExtras(bundle));
		finish();
		hideSoftInput();
	}
}
