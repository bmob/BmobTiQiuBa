package cn.bmob.zuqiu.share;

import java.util.HashMap;

import cn.bmob.zuqiu.utils.LogUtil;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.PlatformActionListener;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.sina.weibo.SinaWeibo;
import cn.sharesdk.system.text.ShortMessage;
import cn.sharesdk.tencent.qq.QQ;
import cn.sharesdk.tencent.qzone.QZone;
import cn.sharesdk.wechat.friends.Wechat;
import cn.sharesdk.wechat.moments.WechatMoments;
import android.app.Activity;
import android.content.Context;
import android.test.ActivityUnitTestCase;
import android.widget.Toast;

public class ZuQiuShare implements PlatformActionListener{
	
	public static final String TAG = ZuQiuShare.class.getSimpleName();
	
	
	private Context context;
	
	public ZuQiuShare(Context context){
		this.context = context;
		init();
	}
	
	private void init(){
		ShareSDK.initSDK(context);
	}
	
	public void shareToQQ(ShareData data){
		QQ.ShareParams sp = new QQ.ShareParams();
		sp.setTitle(data.getTitle());
//		sp.setTitleUrl("http://sharesdk.cn"); // 标题的超链接
		sp.setText(data.getText());
		if(data.getImageUrl()!=null){
			if(data.getImageUrl().startsWith("http"))
				sp.setImageUrl(data.getImageUrl());//"http://assets3.chuangyepu.com/system/startup_contents/logos/000/003/395/medium/data.jpeg");
			else
				sp.setImagePath(data.getImageUrl());
		}
//		sp.setSite("发布分享的网站名称");
//		sp.setSiteUrl("发布分享网站的地址");
		sp.setUrl(data.getUrl());
		sp.setTitleUrl(data.getUrl());
		Platform qzone = ShareSDK.getPlatform (QQ.NAME);
		qzone. setPlatformActionListener (this); // 设置分享事件回调
		// 执行图文分享
		qzone.share(sp);
	}

	public void shareToMsg(ShareData data){
		Toast.makeText(context, "正在调用通讯录...", Toast.LENGTH_LONG).show();
		ShortMessage.ShareParams msg = new ShortMessage.ShareParams();
		msg.text = data.getText();
//		msg.imagePath = Environment.getExternalStorageDirectory()+"/bmshare/data.jpeg";
		Platform plat = ShareSDK.getPlatform (ShortMessage.NAME);
		plat.share(msg);
	}
	
	public void shareToWechat(ShareData data){
		Toast.makeText(context, "正在发消息给微信...", Toast.LENGTH_LONG).show();
		Wechat.ShareParams sp = new Wechat.ShareParams();
		//任何分享类型都需要title和text
		//the two params of title and text are required in every share type
		sp.title = data.getTitle();
		sp.text = data.getText();
		sp.shareType = Platform.SHARE_WEBPAGE;
		sp.url = data.getUrl();
		if(data.getImageUrl()!=null){
			if(data.getImageUrl().startsWith("http"))
				sp.setImageUrl(data.getImageUrl());//"http://assets3.chuangyepu.com/system/startup_contents/logos/000/003/395/medium/data.jpeg");
			else
				sp.setImagePath(data.getImageUrl());
		}
		Platform plat = ShareSDK.getPlatform(Wechat.NAME);
		plat.setPlatformActionListener(this);
		plat.share(sp);
	}
	
	public void shareToWechatMoment(ShareData data){
		Toast.makeText(context, "正在发消息给微信...", Toast.LENGTH_LONG).show();
		WechatMoments.ShareParams sp = new WechatMoments.ShareParams();
		//任何分享类型都需要title和text
		//the two params of title and text are required in every share type
		sp.title = data.getTitle();
		sp.text = data.getText();
		sp.shareType = Platform.SHARE_WEBPAGE;
		sp.url = data.getUrl();
		if(data.getImageUrl()!=null){
			if(data.getImageUrl().startsWith("http"))
				sp.setImageUrl(data.getImageUrl());//"http://assets3.chuangyepu.com/system/startup_contents/logos/000/003/395/medium/data.jpeg");
			else
				sp.setImagePath(data.getImageUrl());
		}
		Platform plat = ShareSDK.getPlatform(Wechat.NAME);
		plat.setPlatformActionListener(this);
		plat.share(sp);
	}
	
	public void shareToQZone(ShareData data){
		QZone.ShareParams sp = new QZone.ShareParams();
		sp.setTitle(data.getTitle());
//		sp.setTitleUrl("http://sharesdk.cn"); // 标题的超链接
		sp.setText(data.getText());
		if(data.getImageUrl()!=null){
			if(data.getImageUrl().startsWith("http"))
				sp.setImageUrl(data.getImageUrl());//"http://assets3.chuangyepu.com/system/startup_contents/logos/000/003/395/medium/data.jpeg");
			else
				sp.setImagePath(data.getImageUrl());
		}
//		sp.setSite("发布分享的网站名称");
//		sp.setSiteUrl("发布分享网站的地址");
		sp.setUrl(data.getUrl());
		Platform qzone = ShareSDK.getPlatform (QZone.NAME);
		qzone. setPlatformActionListener (this); // 设置分享事件回调
		// 执行图文分享
		qzone.share(sp);
	}
	
	public void shareToWeiBo(ShareData data){
		SinaWeibo.ShareParams sp = new SinaWeibo.ShareParams();
		//设置分享内容
		sp.text = data.getText();
		//分享网络图片，新浪分享网络图片，需要申请高级权限,否则会报10014的错误
		//权限申请：新浪开放平台-你的应用中-接口管理-权限申请-微博高级写入接口-statuses/upload_url_text
		//注意：本地图片和网络图片，同时设置时，只分享本地图片
		if(data.getImageUrl()!=null){
			if(data.getImageUrl().startsWith("http"))
				sp.setImageUrl(data.getImageUrl());//"http://assets3.chuangyepu.com/system/startup_contents/logos/000/003/395/medium/data.jpeg");
			else
				sp.setImagePath(data.getImageUrl());
		}
//		sp.imagePath = Environment.getExternalStorageDirectory()+"/bmshare/data.jpeg";
		//初始化新浪分享平台
		Platform pf = ShareSDK.getPlatform(SinaWeibo.NAME);
		//设置分享监听
		pf.setPlatformActionListener(this);
		//执行分享
		pf.share(sp);
	}
	
	@Override
	public void onCancel(Platform arg0, int arg1) {
		// TODO Auto-generated method stub
		LogUtil.i(TAG,"onComplete:"+arg1);
	}

	@Override
	public void onComplete(Platform arg0, int arg1, HashMap<String, Object> arg2) {
		// TODO Auto-generated method stub
		LogUtil.i(TAG,"onComplete:"+arg1);
	}

	@Override
	public void onError(Platform arg0, int arg1, Throwable arg2) {
		// TODO Auto-generated method stub
		LogUtil.i(TAG,"onError:"+arg1+arg2.getMessage());
	}
	
}
