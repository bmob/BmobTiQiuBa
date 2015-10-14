package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

public class ImageUtils {
	
	public static int[] getImageSize(Context context,int drawableId){
		Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), drawableId);
		int width = bitmap.getWidth();
		int height = bitmap.getHeight();
		if(bitmap!=null&&bitmap.isRecycled()){
			bitmap.recycle();
		}
		int size[] = {width,height};
		return size;
	}
	
}
