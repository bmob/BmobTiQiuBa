package cn.bmob.zuqiu.ui;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import at.technikum.mti.fancycoverflow.FancyCoverFlow;
import at.technikum.mti.fancycoverflow.FancyCoverFlowAdapter;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.share.ShareData;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.LogUtil;

public class CompetitionReportActivity extends BaseActivity{

	FancyCoverFlow coverflow;
	private ImageView reportShare;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_report);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarTitle, "比赛报告", 0, View.VISIBLE	);
		coverflow.setAdapter(new ViewGroupExampleAdapter());
		reportShare = (ImageView)findViewById(R.id.report_share);
		reportShare.setOnClickListener(this);
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		coverflow = (FancyCoverFlow)contentView.findViewById(R.id.fancyCoverFlow);
		
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.report_share:
			ShareData data = new ShareData();
			data.setTitle("足球吧比赛报告");
			data.setText("昨天已经过去，未来继续拼搏，中大队VS华师队比赛圆满结束了，我们一起来看精彩记录吧！");
			break;

		default:
			break;
		}
	}
	
	@Override
	protected void onLeftMenuClick() {
		// TODO Auto-generated method stub
		super.onLeftMenuClick();
		finish();
	}
	
    private static class ViewGroupExampleAdapter extends FancyCoverFlowAdapter {

        // =============================================================================
        // Private members
        // =============================================================================

        private int[] images = {R.drawable.ic_launcher, R.drawable.ic_launcher, R.drawable.ic_launcher, R.drawable.ic_launcher};

        // =============================================================================
        // Supertype overrides
        // =============================================================================

        @Override
        public int getCount() {
            return images.length;
        }

        @Override
        public Integer getItem(int i) {
            return images[i];
        }

        @Override
        public long getItemId(int i) {
            return i;
        }

        @Override
        public View getCoverFlowItem(int i, View reuseableView, ViewGroup viewGroup) {
        	LogUtil.i("coverflow","getview"+i);
            CustomViewGroup customViewGroup = null;

            if (reuseableView != null) {
                customViewGroup = (CustomViewGroup) reuseableView;
            } else {
                customViewGroup = new CustomViewGroup(viewGroup.getContext());
                customViewGroup.setLayoutParams(new FancyCoverFlow.LayoutParams(300, 600));
            }

            customViewGroup.getImageView().setImageResource(this.getItem(i));
            customViewGroup.getTextView().setText(String.format("Item %d", i));

            return customViewGroup;
        }
    }

    private static class CustomViewGroup extends LinearLayout {

        // =============================================================================
        // Child views
        // =============================================================================

        private TextView textView;

        private ImageView imageView;

        private Button button;

        // =============================================================================
        // Constructor
        // =============================================================================

        private CustomViewGroup(Context context) {
            super(context);

            this.setOrientation(VERTICAL);

            this.textView = new TextView(context);
            this.imageView = new ImageView(context);
            this.button = new Button(context);

            LinearLayout.LayoutParams layoutParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            this.textView.setLayoutParams(layoutParams);
            this.imageView.setLayoutParams(layoutParams);
            this.button.setLayoutParams(layoutParams);

            this.textView.setGravity(Gravity.CENTER);

            this.imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            this.imageView.setAdjustViewBounds(true);

            this.button.setText("Goto GitHub");
            this.button.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse("https://davidschreiber.github.com/FancyCoverFlow"));
                    view.getContext().startActivity(i);
                }
            });

            this.addView(this.textView);
            this.addView(this.imageView);
            this.addView(this.button);
        }

        // =============================================================================
        // Getters
        // =============================================================================

        private TextView getTextView() {
            return textView;
        }

        private ImageView getImageView() {
            return imageView;
        }
    }
	
}
