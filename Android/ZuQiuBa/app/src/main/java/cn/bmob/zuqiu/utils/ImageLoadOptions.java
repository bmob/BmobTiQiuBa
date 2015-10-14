package cn.bmob.zuqiu.utils;

import android.graphics.Bitmap;

import cn.bmob.zuqiu.R;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class ImageLoadOptions {

	/** 新闻列表中用到的图片加载配置 */
	public static DisplayImageOptions getOptions(int loadingbg,int degree) {
		DisplayImageOptions.Builder options = new DisplayImageOptions.Builder();
				// // 设置图片在下载期间显示的图片
			if(loadingbg!=-1)
				options.showImageOnLoading(loadingbg)
				// // 设置图片Uri为空或是错误的时候显示的图片
				// .showImageForEmptyUri(R.drawable.small_image_holder_listpage)
				// // 设置图片加载/解码过程中错误时候显示的图片
				.showImageOnFail(loadingbg);
		options.cacheInMemory(true)
				// 设置下载的图片是否缓存在内存中
				.cacheOnDisc(true)
				// 设置下载的图片是否缓存在SD卡中
				.considerExifParams(true)
				.imageScaleType(ImageScaleType.EXACTLY)// 设置图片以如何的编码方式显示
				.bitmapConfig(Bitmap.Config.RGB_565)// 设置图片的解码类型
				// .decodingOptions(android.graphics.BitmapFactory.Options
				// decodingOptions)//设置图片的解码配置
				.considerExifParams(true)
				// 设置图片下载前的延迟
				// .delayBeforeLoading(int delayInMillis)//int
				// delayInMillis为你设置的延迟时间
				// 设置图片加入缓存前，对bitmap进行设置
				// 。preProcessor(BitmapProcessor preProcessor)
				.resetViewBeforeLoading(true);// 设置图片在下载前是否重置，复位
				if(degree>0){
					options.displayer(new RoundedBitmapDisplayer(degree));//是否设置为圆角，弧度为多少
				}else{
			    options.displayer(new FadeInBitmapDisplayer(100));// 淡入
				}
				
				
		return options.build();
	}

	
	public static DisplayImageOptions getOptionsForRounded() {
		DisplayImageOptions options = new DisplayImageOptions.Builder()  
	    .showImageOnFail(R.drawable.ic_launcher)  
	    .cacheInMemory(true)  
	    .cacheOnDisc(false)  
	    .displayer(new RoundedBitmapDisplayer(20))  
	    .build();
		return options;  
	}
	public static DisplayImageOptions getRoundedOptions(int drawbleId,int degree){
		DisplayImageOptions options = new DisplayImageOptions.Builder()
		.showImageOnLoading(drawbleId)
		.showImageForEmptyUri(drawbleId)
		.showImageOnFail(drawbleId)
		.cacheInMemory(true)
		.cacheOnDisk(true)
		.considerExifParams(true)
		.displayer(new RoundedBitmapDisplayer(degree))
		.build();
		return options;
	}
}
