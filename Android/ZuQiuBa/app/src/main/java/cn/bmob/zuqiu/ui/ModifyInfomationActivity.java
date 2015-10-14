package cn.bmob.zuqiu.ui;


import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import com.bmob.BmobProFile;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.datatype.BmobFile;
import cn.bmob.v3.listener.ResetPasswordListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.v3.listener.UploadFileListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.ImageUtils;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PhotoUtil;
import cn.bmob.zuqiu.utils.TimeUtils;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiu.view.views.CityPicker;
import cn.bmob.zuqiu.view.views.DatePicker;
import cn.bmob.zuqiuj.bean.City;
import cn.bmob.zuqiuj.bean.User;

public class ModifyInfomationActivity extends BaseActivity{
	private String nickName ;
	private AlertDialog mDialog;
	
	private ImageView modifyUserLogo;
	private RelativeLayout accountInfo;
	private TextView accountContent;
	
	private RelativeLayout nickInfo;
	private TextView nickContent;
	
	private RelativeLayout passwordInfo;
	private TextView pwdContent;
	
	private RelativeLayout birthInfo;
	private TextView birthContent;
	
	private RelativeLayout locationInfo;
	private TextView locationContent;
	
	private RelativeLayout goodatInfo;
	private TextView goodatContent;
	
	private RelativeLayout heightInfo;
	private TextView heightContent;
	
	private RelativeLayout weightInfo;
	private TextView weightContent;
	
	private RelativeLayout cityInfo;
	private TextView cityContent;
	
	
	private String cityCode = "";
	private String cityName = "";
	public static int GET_CITY = 5;
	public static int GET_LOCATION = 6;
	public static int GET_GOOD_AT = 7;
	public BmobDate birthDate = null;
	private int locationIndex ;
	private int goodatIndex;
	private User user;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_modify_info);
		user = BmobUser.getCurrentUser(mContext, User.class);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
        setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
        
        if(user != null){
        	if(user.getNickname()!=null){
        		nickName = user.getNickname();
        	}else{
        		nickName = user.getUsername();
        	}
        }
        setUpAction(mActionBarTitle, nickName, 0, View.VISIBLE);
        initViews(user);
	}
	
	private void initViews(User user){
		accountContent.setText(user.getUsername());
		if(user.getAvator()!=null){
			ImageLoader.getInstance().displayImage(user.getAvator().getFileUrl(mContext),
					modifyUserLogo, ImageLoadOptions.getRoundedOptions(R.drawable.modify_user_logo_default, 180),new SimpleImageLoadingListener(){

						@Override
						public void onLoadingComplete(String imageUri,
								View view, Bitmap loadedImage) {
							// TODO Auto-generated method stub
							super.onLoadingComplete(imageUri, view, loadedImage);
							int[] size = ImageUtils.getImageSize(ModifyInfomationActivity.this, R.drawable.modify_user_logo_default);
							FrameLayout.LayoutParams rp = new FrameLayout.LayoutParams(size[0], size[1]);
							rp.gravity = Gravity.CENTER;
							modifyUserLogo.setLayoutParams(rp);
						}
    			
    		});
		}
		if(!TextUtils.isEmpty(user.getNickname())){
			nickContent.setText(user.getNickname());
		}
		if(user.getBirthday()!=null){
			birthContent.setText(user.getBirthday().getDate().substring(0, 10));
		}
		locationContent.setText(getUserLocation(user.getMidfielder()));
		goodatContent.setText(getGoodat(user.getBe_good()));
		heightContent.setText(user.getHeight()+"cm");
		weightContent.setText(user.getWeight()+"kg");
		cityContent.setText(user.getCityname());
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		modifyUserLogo = (ImageView)contentView.findViewById(R.id.modify_user_logo);
		
		accountInfo = (RelativeLayout)contentView.findViewById(R.id.account_info);
		accountContent = (TextView)contentView.findViewById(R.id.account_content);
	
		nickInfo = (RelativeLayout)contentView.findViewById(R.id.nick_info);
		nickContent = (TextView)contentView.findViewById(R.id.nick_content);
		
		passwordInfo = (RelativeLayout)contentView.findViewById(R.id.password_info);
		pwdContent = (TextView)contentView.findViewById(R.id.pwd_content);
		
		birthInfo = (RelativeLayout)contentView.findViewById(R.id.birth_info);
		birthContent = (TextView)contentView.findViewById(R.id.birth_content);
	
		locationInfo = (RelativeLayout)contentView.findViewById(R.id.location_info);
		locationContent = (TextView)contentView.findViewById(R.id.location_content);
		
		goodatInfo = (RelativeLayout)contentView.findViewById(R.id.goodat_info);
		goodatContent = (TextView)contentView.findViewById(R.id.goodat_content);
	
		heightInfo = (RelativeLayout)contentView.findViewById(R.id.height_info);
		heightContent = (TextView)contentView.findViewById(R.id.height_content);
	
		weightInfo = (RelativeLayout)contentView.findViewById(R.id.weight_info);
		weightContent = (TextView)contentView.findViewById(R.id.weight_content);
	
		cityInfo = (RelativeLayout)contentView.findViewById(R.id.city_info);
		cityContent = (TextView)contentView.findViewById(R.id.city_content);
	
		modifyUserLogo.setOnClickListener(this);
		passwordInfo.setOnClickListener(this);
		birthInfo.setOnClickListener(this);
		locationInfo.setOnClickListener(this);
		goodatInfo.setOnClickListener(this);
		cityInfo.setOnClickListener(this);
		nickInfo.setOnClickListener(this);
		heightInfo.setOnClickListener(this);
		weightInfo.setOnClickListener(this);
	}
	
	

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.modify_user_logo:
			showLogoDialog();
			break;
		case R.id.take_pic:
			takePhoto();
			dismissLogoDialog();
			break;
		case R.id.choose_from_album:
			getAlbumn();
			dismissLogoDialog();
			break;
		case R.id.choose_cancel:
			dismissLogoDialog();
			break;
		case R.id.password_info:
//			getIdentifyCodeForResetPassword("13466303209");
			Intent intent7 = new Intent();
			intent7.setClass(mContext, ModifyPassWordActivity_2.class);
			startActivity(intent7);
			break;
		case R.id.birth_info:
			showTimeDialog();
			break;
		case R.id.location_info:
			Intent intent2 = new Intent();
			intent2.setClass(mContext, SigleChoiceActivity.class);
			intent2.putExtra("data", "location");
			startActivityForResult(intent2, 6);
			break;
		case R.id.goodat_info:
			Intent intent3 = new Intent();
			intent3.setClass(mContext, SigleChoiceActivity.class);
			intent3.putExtra("data", "goodat");
			startActivityForResult(intent3,7);
			break;
		case R.id.city_info:
//			Intent intent = new Intent();
//			intent.setClass(mContext, CityChooseActivity.class);
//			startActivityForResult(intent, 5);
            showSelectCityDialog();
			break;
		case R.id.nick_info:
			Intent intent4 = new Intent();
			intent4.setClass(mContext, ModifyItemActivity.class);
			intent4.putExtra("modify_type", 1);
			startActivityForResult(intent4, 8);
			break;
		case R.id.weight_info:
			Intent intent5 = new Intent();
			intent5.setClass(mContext, ModifyItemActivity.class);
			intent5.putExtra("modify_type", 2);
			startActivityForResult(intent5, 9);
			break;
		case R.id.height_info:
			Intent intent6 = new Intent();
			intent6.setClass(mContext, ModifyItemActivity.class);
			intent6.putExtra("modify_type", 3);
			startActivityForResult(intent6, 10);
			break;
		default:
			break;
		}
	}
	
	Dialog timeDialog = null;
	private void showTimeDialog(){
		if(timeDialog == null){
			timeDialog = new AlertDialog.Builder(ModifyInfomationActivity.this).create();
		}
		timeDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(ModifyInfomationActivity.this).inflate(
				R.layout.dialog_date_picker, null);
		timeDialog.show();
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.CENTER);
		timeDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth()-30,
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
		final DatePicker datePicker = (DatePicker)view.findViewById(R.id.datePicker);
        datePicker.setDefaultYear(1994);    //设置当前年
		Button commit = (Button)view.findViewById(R.id.date_commit);
		commit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Calendar mCalendar = Calendar.getInstance();
				mCalendar.set(Calendar.YEAR, datePicker.getYear());
				mCalendar.set(Calendar.MONTH, datePicker.getMonth());
				mCalendar.set(Calendar.DAY_OF_MONTH, datePicker.getDay());
				mCalendar.set(Calendar.HOUR_OF_DAY, 0);
				mCalendar.set(Calendar.MINUTE,0);
				mCalendar.set(Calendar.SECOND, 0);
				birthDate = new BmobDate(mCalendar.getTime());
				birthContent.setText(new BmobDate(mCalendar.getTime()).getDate().substring(0, 10));
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
	}

    /**
     * 打开城市选择对话框
     */
    private void showSelectCityDialog(){
        final Dialog timeDialog = new AlertDialog.Builder(ModifyInfomationActivity.this).create();
        View view = LayoutInflater.from(ModifyInfomationActivity.this).inflate(
                R.layout.dialog_city_picker, null);
        
        timeDialog.setCanceledOnTouchOutside(true);
        timeDialog.show();
        timeDialog.setContentView(view);
        final CityPicker cityPicker = (CityPicker) view.findViewById(R.id.cityPicker);
        view.findViewById(R.id.date_commit).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
//                showToast("您选择的城市是："+cityPicker.getCity_string()+cityPicker.getcity_name()+"----"+cityPicker.getCounty_code()+"  市代码："+cityPicker.getCity_code());
                cityContent.setText(cityPicker.getCity_string());
                cityName = cityPicker.getCity_string();
                cityCode = cityPicker.getCity_code();
                timeDialog.cancel();
            }
        });
        view.findViewById(R.id.btn_cancel).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                timeDialog.cancel();
            }
        });
    }
	
	
	private void getIdentifyCodeForResetPassword(String phoneNumber){
		BmobUser.resetPasswordByPhone(this, phoneNumber, new ResetPasswordListener() {
			
			@Override
			public void onSuccess() {
				// TODO Auto-generated method stub
				LogUtil.i(TAG,"获取验证码成功。");
				ToastUtil.showToast(getApplicationContext(), "获取验证码成功");
			}
			
			@Override
			public void onFailure(int arg0, String arg1) {
				// TODO Auto-generated method stub
				LogUtil.i(TAG,"获取验证码失败。");
				ToastUtil.showToast(getApplicationContext(), "获取验证码失败。");
			}
		});
	}
	
	private void getAlbumn() {
		// TODO Auto-generated method stub
		Intent intent = new Intent(Intent.ACTION_PICK, null);
		intent.setDataAndType(
				MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
		startActivityForResult(intent,
				Constant.REQUESTCODE_UPLOADAVATAR_LOCATION);
	}
	
	
	String filePath = "";
	private void takePhoto() {
		// TODO Auto-generated method stub
		File dir = new File(Constant.BMOB_AVATAR_DIR);
		if (!dir.exists()) {
			dir.mkdirs();
		}
		// 原图
		File file = new File(dir, new SimpleDateFormat("yyMMddHHmmss")
				.format(new Date()));
		filePath = file.getAbsolutePath();// 获取相片的保存路径
		Uri imageUri = Uri.fromFile(file);

		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
		startActivityForResult(intent,
				Constant.REQUESTCODE_UPLOADAVATAR_CAMERA);
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
		if(TextUtils.isEmpty(path)&&user.getAvator()==null){
			showToast("请设置头像");
			return;
		}
		if(TextUtils.isEmpty(nickContent.getText().toString().trim())&&
				user.getNickname()==null){
			showToast("请填写昵称");
			return;
		}
		if(birthDate == null&&user.getBirthday()==null){
			showToast("请选择生日");
			return;
		}
		if(TextUtils.isEmpty(cityCode)&&user.getCity()==null){
			showToast("请选择城市");
			return;
		}
		
		uploadAvatar(path);
		
	}
	
	
	private void uploadAvatar(String path){
		if(TextUtils.isEmpty(path)){
			updateUserInfo(null);
		}else{
			final BmobFile bmobFile = new BmobFile(new File(path));
			bmobFile.upload(this, new UploadFileListener() {
				
				@Override
				public void onSuccess() {
					// TODO Auto-generated method stub
					String url = bmobFile.getFileUrl(mContext);
					//设置头像
					avatorUrl = url;
					LogUtil.i("avator", avatorUrl);
					//更新头像
	//				refreshAvatar(avatorUrl);
					//更新BmobUser对象
					updateUserInfo(bmobFile);
				}
				
				@Override
				public void onProgress(Integer arg0) {
					// TODO Auto-generated method stub
					
					
				}
				
				@Override
				public void onFailure(int arg0, String msg) {
					// TODO Auto-generated method stub
					showToast("头像上传失败："+msg);
				}
			});
		}
	}
	
	private void updateUserInfo(BmobFile file){
		
		User user = BmobUser.getCurrentUser(mContext, User.class);
		if(file!=null){
			user.setAvator(file);
		}
		user.setNickname(nickContent.getText().toString().trim());
		user.setBirthday(new BmobDate(TimeUtils.getDateByString(birthContent.getText().toString()+" 00:00:00")));
		user.setMidfielder(getLocation(locationContent.getText().toString()));
		user.setBe_good(getGood(goodatContent.getText().toString()));
		String height = heightContent.getText().toString().trim();
		String weight = weightContent.getText().toString().trim();
		user.setHeight(Float.parseFloat(height.substring(0, height.lastIndexOf("cm"))));
		user.setWeight(Float.parseFloat(weight.substring(0, weight.lastIndexOf("kg"))));
		if(cityCode!=null){
			user.setCity(cityCode);
		}
		user.setCityname(cityContent.getText().toString());
		user.update(mContext, new UpdateListener() {
			
			@Override
			public void onSuccess() {
				// TODO Auto-generated method stub
				showToast("更新信息成功。");
				setResult(RESULT_OK);
				finish();
			}
			
			@Override
			public void onFailure(int arg0, String arg1) {
				// TODO Auto-generated method stub
				showToast("更新信息失败。");
			}
		});
	}
	
	
	Bitmap newBitmap;
	boolean isFromCamera = false;// 区分拍照旋转
	int degree = 0;
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		switch (requestCode) {
			case Constant.REQUESTCODE_UPLOADAVATAR_CAMERA:// 拍照修改头像
			if (resultCode == RESULT_OK) {
				if (!Environment.getExternalStorageState().equals(
						Environment.MEDIA_MOUNTED)) {
					showToast("SD不可用");
					return;
				}
				isFromCamera = true;
				File file = new File(filePath);
				
				startImageAction(Uri.fromFile(file), 200, 200,
						Constant.REQUESTCODE_UPLOADAVATAR_CROP, true);
			}
			break;
			case Constant.REQUESTCODE_UPLOADAVATAR_CROP:// 裁剪头像返回
				// TODO sent to crop
				if (data == null) {
					// Toast.makeText(this, "取消选择", Toast.LENGTH_SHORT).show();
					return;
				} else {
					saveCropAvator(data);
				}
				// 初始化文件路径
				filePath = "";
				// 上传头像
//				uploadAvatar();
				break;
			case Constant.REQUESTCODE_UPLOADAVATAR_LOCATION:// 本地修改头像
				Uri uri = null;
				if (data == null) {
					return;
				}
				if (resultCode == RESULT_OK) {
					if (!Environment.getExternalStorageState().equals(
							Environment.MEDIA_MOUNTED)) {
						showToast("SD不可用");
						return;
					}
					isFromCamera = false;
					uri = data.getData();
//					Bitmap bit = BitmapFactory.decodeResource(getResources(), R.drawable.team_logo_default);
//					int width = bit.getWidth();
//					int height = bit.getHeight();
					startImageAction(uri, 200, 200,
							Constant.REQUESTCODE_UPLOADAVATAR_CROP, true);
//					if(bit!=null&&!bit.isRecycled()){
//						bit.recycle();
//					}
				} else {
					showToast("照片获取失败");
				}

				break;
			case 5:
				if (resultCode == RESULT_OK) {
					Bundle bundle = data.getExtras();
					City city = (City) bundle.getSerializable("city");
					cityContent.setText(city.getCity_name());
					cityName = city.getCity_name();
					cityCode = city.getCityId();
				}
				break;
			case 6://获取场上位置
				if (resultCode == RESULT_OK) {
					int index = data.getIntExtra("result", 0);
					locationContent.setText(getUserLocation(index));
					locationIndex = index;
				}
				break;
			case 7://获取擅长脚
				if (resultCode == RESULT_OK) {
					int index = data.getIntExtra("result", 0);
					goodatContent.setText(getGoodat(index));
					goodatIndex = index;
				}
				break;
			case 8:
				if(resultCode == RESULT_OK){
					Bundle bundle = data.getExtras();
					String content = bundle.getString("content");
					if(!TextUtils.isEmpty(content)){
						nickContent.setText(content);
					}
				}
				break;
			case 9:
				if(resultCode == RESULT_OK){
					Bundle bundle = data.getExtras();
					String content = bundle.getString("content");
					if(!TextUtils.isEmpty(content)){
						weightContent.setText(content+"kg");
					}
				}
				break;
			case 10:
				if(resultCode == RESULT_OK){
					Bundle bundle = data.getExtras();
					String content = bundle.getString("content");
					if(!TextUtils.isEmpty(content)){
						heightContent.setText(content+"cm");
					}
				}
				break;
		default:
			break;

		}
	}
	
	
	
	/**
	 * startImageAction
	 * 
	 * @Title: startImageAction
	 * @return void
	 * @throws
	 */
	private void startImageAction(Uri uri, int outputX, int outputY,
			int requestCode, boolean isCrop) {
		Intent intent = null;
		if (isCrop) {
			intent = new Intent("com.android.camera.action.CROP");
		} else {
			intent = new Intent(Intent.ACTION_GET_CONTENT, null);
		}
		intent.setDataAndType(uri, "image/*");
		intent.putExtra("crop", "true");
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		intent.putExtra("outputX", outputX);
		intent.putExtra("outputY", outputY);
		intent.putExtra("scale", true);
		intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
		intent.putExtra("return-data", true);
		intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
		intent.putExtra("noFaceDetection", true); // no face detection
		startActivityForResult(intent, requestCode);
	}
	
	
	/**
	 * 保存裁剪的头像
	 * @param data
	 */
	String path = "";
	String avatorUrl = "";
	private void saveCropAvator(Intent data) {
		Bundle extras = data.getExtras();
		if (extras != null) {
			Bitmap bitmap = extras.getParcelable("data");
			Log.i("life", "avatar - bitmap = " + bitmap);
			if (bitmap != null) {
				
//				modifyUserLogo.setImageBitmap(bitmap);
				
				// 保存图片
				String filename = new SimpleDateFormat("yyMMddHHmmss")
						.format(new Date())+".jpg";
				path = Constant.BMOB_AVATAR_DIR + filename;
				
				PhotoUtil.saveBitmap(Constant.BMOB_AVATAR_DIR, filename,
						bitmap, false);
				// 上传头像
				if (bitmap != null && bitmap.isRecycled()) {
					bitmap.recycle();
				}
			
				ImageLoader.getInstance().displayImage("file://"+Constant.BMOB_AVATAR_DIR+filename,
						modifyUserLogo, ImageLoadOptions.getRoundedOptions(R.drawable.modify_user_logo_default, 180),new SimpleImageLoadingListener(){

							@Override
							public void onLoadingComplete(String imageUri,
									View view, Bitmap loadedImage) {
								// TODO Auto-generated method stub
								super.onLoadingComplete(imageUri, view, loadedImage);
								int[] size = ImageUtils.getImageSize(ModifyInfomationActivity.this, R.drawable.modify_user_logo_default);
								FrameLayout.LayoutParams rp = new FrameLayout.LayoutParams(size[0], size[1]);
								rp.gravity = Gravity.CENTER;
								modifyUserLogo.setLayoutParams(rp);
							}
	    			
	    		});
			
			}
		}
	}
	
	private void showLogoDialog(){
			if(mDialog == null){
				mDialog = new AlertDialog.Builder(ModifyInfomationActivity.this).create();
			}
		    mDialog.setCanceledOnTouchOutside(false);

			View view = LayoutInflater.from(ModifyInfomationActivity.this).inflate(
					R.layout.dialog_choose_logo, null);
			mDialog.show();
			mDialog.setContentView(view);
			mDialog.getWindow().setGravity(Gravity.BOTTOM);
			mDialog.getWindow().setLayout(
					getWindowManager().getDefaultDisplay().getWidth(),
					android.view.WindowManager.LayoutParams.WRAP_CONTENT);
			Button takePic = (Button)view.findViewById(R.id.take_pic);
			Button getAlbum = (Button)view.findViewById(R.id.choose_from_album);
			Button cancel = (Button)view.findViewById(R.id.choose_cancel);
			takePic.setOnClickListener(this);
			getAlbum.setOnClickListener(this);
			cancel.setOnClickListener(this);
	}
	
	private void dismissLogoDialog(){
		if(mDialog!=null&&mDialog.isShowing()){
			mDialog.dismiss();
		}
	}
	
    /**
     * 根据枚举值返回球员场上位置
     * @param location
     * @return
     */
	private String getUserLocation(Integer location){
        if(location == null){
            return "";
        }

		switch (location) {
		case 1:
			return "门将";
		case 2:
			return "后卫";
		case 3:
			return "中场";
		case 4:
			return "前锋";
		default:
			break;
		}
		return "前锋";
	}
	
	private int getLocation(String loca){
		if(loca == null){
			return 0;
		}
		if(loca.equals("门将")){
			return 1;
		}else if(loca.equals("后卫")){
			return 2;
		}else if(loca.equals("中场")){
			return 3;
		}else if(loca.equals("前锋")){
			return 4;
		}
		return 0;
	}
	
	/**
	 * 根据枚举值返回擅长脚
	 * @param leg
	 * @return
	 */
	private String getGoodat(Integer leg){
        if(leg == null){
            return "";
        }
		switch (leg) {
		case 1:
			return "左脚";
		case 2:
			return "右脚";
		case 3:
			return "左右开弓";
		case 4:
			break;
		}
		return "左脚";
	}
	
	
	private int getGood(String good){
		if(good == null){
			return 0;
		}
		if(good.equals("左脚")){
			return 1;
		}else if(good.equals("右脚")){
			return 2;
		}else if(good.equals("左右开弓")){
			return 3;
		}
		return 0;
	}
	
}




