/**
 * 
 */
package cn.bmob.zuqiu.share;

import cn.bmob.zuqiu.R;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.GridView;
import android.widget.TextView;

import com.umeng.analytics.MobclickAgent;

/**
 * @author venus
 *
 */
public class ShareDialog extends Dialog implements OnClickListener,OnItemClickListener{

	private Context context;
	private Button cancelButton;
	private GridView sharePlatform;
	private ShareData shareData;
	private ZuQiuShare share;
	/**
	 * @param context
	 */
	public ShareDialog(Context context) {
		super(context);
		this.context = context;
	}

	/**
	 * @param context
	 * @param theme
	 */
	public ShareDialog(Context context, int theme) {
		super(context, theme);
		this.context = context;
	}
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.dialog_share);
		
		share = new ZuQiuShare(context);
		cancelButton = (Button) findViewById(R.id.dialog_share_cancel);
		sharePlatform = (GridView) findViewById(R.id.dialog_share_platforms);
		sharePlatform.setAdapter(new ShareAdapter());
		
		cancelButton.setOnClickListener(this);
		sharePlatform.setOnItemClickListener(this);
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		// TODO Auto-generated method stub "微信好友","朋友圈","新浪微博","QQ好友","QQ空间","短信"
		if(shareData==null){
			return;
		}
		switch (position) {
		case 0:
			share.shareToWechat(shareData);
            MobclickAgent.onEvent(this.context, "shareToWechat");
			break;
		case 1:
			share.shareToWechatMoment(shareData);
            MobclickAgent.onEvent(this.context, "shareToWechatMoment");
			break;
		case 2:
			share.shareToWeiBo(shareData);
            MobclickAgent.onEvent(this.context, "shareToWeiBo");
			break;
		case 3:
			share.shareToQQ(shareData);
            MobclickAgent.onEvent(this.context, "shareToQQ");
			break;
		case 4:
			share.shareToQZone(shareData);
            MobclickAgent.onEvent(this.context, "shareToQZone");
			break;
		case 5:
			share.shareToMsg(shareData);
            MobclickAgent.onEvent(this.context, "shareToMsg");
			break;
		}
		dismiss();
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.dialog_share_cancel:
			dismiss();
			break;
		}
	}

	
	public ShareData getShareData() {
		return shareData;
	}

	public void setShareData(ShareData shareData) {
		this.shareData = shareData;
	}




	public class ShareAdapter extends BaseAdapter{

		private String[] platsNames = {"微信好友","朋友圈","新浪微博","QQ好友","QQ空间","短信"};
		private int[] icons = {R.drawable.pf_wechat,R.drawable.pf_wc_moment,
			R.drawable.pf_sina,R.drawable.pf_qq,
			R.drawable.pf_qq,R.drawable.pf_msg};
		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			return platsNames.length;
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			return platsNames[position];
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			// TODO Auto-generated method stub
			ViewHolder holder = null ;
			if(convertView==null){
				holder = new ViewHolder();
				convertView = View.inflate(getContext(), R.layout.item_share, null);
				holder.platform = (TextView) convertView.findViewById(R.id.share_platform);
				convertView.setTag(holder);
			}else{
				holder = (ViewHolder) convertView.getTag();
			}
			holder.platform.setText(platsNames[position]);
			holder.platform.setCompoundDrawablesWithIntrinsicBounds(0, icons[position], 0, 0);
			
			return convertView;
		}
		
	}
	
	public class ViewHolder{
		TextView platform;
	}
}
