package cn.bmob.zuqiu.share;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import cn.bmob.zuqiu.utils.LogUtil;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;

public class ScreenShot {

	public static Bitmap takeScreenshotForView(View view) {
		view.setDrawingCacheEnabled(true);
		view.buildDrawingCache();
		Bitmap tempBit = view.getDrawingCache();
		Rect frame = new Rect();
		view.getWindowVisibleDisplayFrame(frame);
		int width = view.getWidth();
		int height = view.getHeight();
		Bitmap bitmap = Bitmap.createBitmap(tempBit, 0, 0, width, height);
		view.destroyDrawingCache();
		return bitmap;
	}

	public static Bitmap takeScreenshotForActivity(Activity activity) {
		View view = activity.getWindow().getDecorView();
		view.setDrawingCacheEnabled(true);
		view.buildDrawingCache();
		Bitmap tempBit = view.getDrawingCache();
		Rect frame = new Rect();
		view.getWindowVisibleDisplayFrame(frame);
		int statusBarHeight = frame.top;
		int width = view.getWidth();
		int height = view.getHeight();
		Bitmap bitmap = Bitmap.createBitmap(tempBit, 0, statusBarHeight, width,
				height - statusBarHeight);
		view.destroyDrawingCache();
		return bitmap;
	}

	public static Drawable BitmapToDrawable(Bitmap bitmap) {
		@SuppressWarnings("deprecation")
		BitmapDrawable bd = new BitmapDrawable(bitmap);
		Drawable drawable = (Drawable) bd;
		return drawable;
	}

	public static String savePic(Bitmap bitmap, String fileName) {
		try {
			File file = new File(fileName);
			if (!file.getParentFile().exists()) {
				file.getParentFile().mkdirs();
			}
			FileOutputStream fos = null;
			fos = new FileOutputStream(file);
			bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
			fos.flush();
			fos.close();
			LogUtil.i("share", file.getAbsolutePath());
			return file.getAbsolutePath();
		} catch (FileNotFoundException e) {
			LogUtil.i("share", ""+e.getMessage());
			e.printStackTrace();
			return null;
		} catch (IOException e) {
			LogUtil.i("share", ""+e.getMessage());
			e.printStackTrace();
			return null;
		}
	}

	public static byte[] getBytes(Bitmap bitmap) {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.JPEG, 100, out);
		try {
			out.flush();
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return out.toByteArray();
	}

	interface ISharePicCallBack {
		public final static int SHARE_OK = 1;
		public final static int SHARE_NOTOK = 2;

		public void shareResult(int resultCode, String output);
	}

	public static void share(final String urlStr, final Bitmap bitmap,
			final ISharePicCallBack callBack) {
		new Thread() {
			public void run() {
				try {
					URL url = new URL(urlStr);
					HttpURLConnection httpConn = (HttpURLConnection) url
							.openConnection();
					httpConn.setDoOutput(true);
					httpConn.setDoInput(true);
					httpConn.setUseCaches(false);
					httpConn.setRequestMethod("POST");
					byte[] requestStringBytes = getBytes(bitmap);
					httpConn.setRequestProperty("Content-length", ""
							+ requestStringBytes.length);
					httpConn.setRequestProperty("Content-Type",
							"application/octet-stream");
					httpConn.setRequestProperty("Connection", "Keep-Alive");
					httpConn.setRequestProperty("Charset", "UTF-8");
					OutputStream outputStream = httpConn.getOutputStream();
					outputStream.write(requestStringBytes);
					outputStream.flush();
					outputStream.close();
					if (HttpURLConnection.HTTP_OK == httpConn.getResponseCode()) {
						StringBuffer sb = new StringBuffer();
						String readLine;
						BufferedReader responseReader;
						responseReader = new BufferedReader(
								new InputStreamReader(
										httpConn.getInputStream(), "UTF-8"));
						while ((readLine = responseReader.readLine()) != null) {
							sb.append(readLine).append("\n");
						}
						responseReader.close();
						callBack.shareResult(ISharePicCallBack.SHARE_OK,
								sb.toString());
					} else {
						callBack.shareResult(ISharePicCallBack.SHARE_NOTOK, ""
								+ httpConn.getResponseCode());
					}
				} catch (IOException e) {
					callBack.shareResult(ISharePicCallBack.SHARE_NOTOK, "");
					e.printStackTrace();
				}
			};
		}.start();
	}
}
