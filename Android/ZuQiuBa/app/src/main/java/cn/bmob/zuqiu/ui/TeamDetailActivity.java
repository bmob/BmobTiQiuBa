package cn.bmob.zuqiu.ui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.datatype.BmobFile;
import cn.bmob.v3.listener.FindListener;
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
import cn.bmob.zuqiu.view.views.CityPicker;
import cn.bmob.zuqiu.view.views.DatePicker;
import cn.bmob.zuqiuj.bean.City;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class TeamDetailActivity extends BaseActivity{

	ImageView teamLogo;
	
	RelativeLayout teamNameLayout;
	TextView teamNameInput;
	
	RelativeLayout teamCityLayout;
	TextView teamCityView;
	
	RelativeLayout teamFoundTimeLayout;
	TextView teamFoundTime;
	
	RelativeLayout registerLayout;
	TextView registerCodeInput;
	
	RelativeLayout changeCaptain;
	TextView teamCaptainName;
	
	RelativeLayout teamIntroduce;
	TextView teamIntroInput;
	
	Team currentTeam;
	
	private AlertDialog mDialog;
	
	private String teamName;
	private String teamCity;
	private BmobDate teamDate;
	private String registerCode;
	private String captainName;
	private String intro;
	private User captain;
	private String cityName;
	
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_team_detail);
		setUpAction(mActionBarTitle, "球队资料", 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "",R.drawable.commit_actionbar,View.VISIBLE);
		
		currentTeam = (Team) getIntent().getSerializableExtra("team");
		initTeamInfo(currentTeam);
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		teamLogo = (ImageView)contentView.findViewById(R.id.team_logo);
		teamNameLayout = (RelativeLayout)contentView.findViewById(R.id.team_name);
		teamNameInput = (TextView)contentView.findViewById(R.id.team_name_content);
		
		teamCityLayout = (RelativeLayout)contentView.findViewById(R.id.team_city);
		teamCityView = (TextView)contentView.findViewById(R.id.team_city_content);
		
		teamFoundTimeLayout = (RelativeLayout)contentView.findViewById(R.id.team_found);
		teamFoundTime = (TextView)contentView.findViewById(R.id.team_found_content);
		
		registerLayout = (RelativeLayout)contentView.findViewById(R.id.team_register);
		registerCodeInput = (TextView)contentView.findViewById(R.id.team_regsiter_content);
		
		changeCaptain = (RelativeLayout)contentView.findViewById(R.id.team_change);
		teamCaptainName = (TextView)contentView.findViewById(R.id.team_change_content);
		teamIntroduce = (RelativeLayout)contentView.findViewById(R.id.team_intro);
		teamIntroInput = (TextView)contentView.findViewById(R.id.team_intro_content);
		
		setListenter();

	}
	
	private void setListenter(){
		
		
		teamLogo.setOnClickListener(this);
		teamNameLayout.setOnClickListener(this);
		teamCityLayout.setOnClickListener(this);
		teamFoundTimeLayout.setOnClickListener(this);
		registerLayout.setOnClickListener(this);
		changeCaptain.setOnClickListener(this);
		teamIntroduce.setOnClickListener(this);
	}
	
	private void initTeamInfo(Team team){
        
		if(team.getAvator()!=null){
			ImageLoader.getInstance().displayImage(team.getAvator().getFileUrl(mContext),
    				teamLogo, ImageLoadOptions.getRoundedOptions(R.drawable.team_logo_default, 0),new SimpleImageLoadingListener(){

						@Override
						public void onLoadingComplete(String imageUri,
								View view, Bitmap loadedImage) {
							// TODO Auto-generated method stub
							super.onLoadingComplete(imageUri, view, loadedImage);
							int[] size = ImageUtils.getImageSize(mContext, R.drawable.team_logo_default);
							LinearLayout.LayoutParams rp = new LinearLayout.LayoutParams(size[0], size[1]);
							rp.gravity = Gravity.CENTER_HORIZONTAL;
							rp.setMargins(16, 16, 16, 16);
							teamLogo.setLayoutParams(rp);
						}
    		});
		}
		
		teamNameInput.setText(team.getName());
		if(team.getCityname()!=null)
			teamCityView.setText(team.getCityname());
		if(team.getFound_time()!=null)
			teamFoundTime.setText(TimeUtils.getCurrentYear(team.getFound_time()));
		if(team.getCaptain()!=null){
			if(team.getCaptain().getNickname()!=null){
				teamCaptainName.setText(team.getCaptain().getNickname());
			}else{
				teamCaptainName.setText(team.getCaptain().getUsername());
			}
		}
		registerCodeInput.setText(team.getGsl_code()+"");
		if(team.getAbout()!=null)
			teamIntroInput.setText(team.getAbout());
		
	}
	
	
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.team_change:
			Intent intent = new Intent();
			intent.setClass(mContext, ChangeCaptainActivity.class);
			intent.putExtra("team", currentTeam);
			startActivityForResult(intent,11);
			break;
		case R.id.team_logo:
			showLogoDialog();
			break;
		case R.id.team_name:
			Intent intent2 = new Intent();
			intent2.setClass(mContext, InputActivity.class);
			intent2.putExtra("input_type", 1);
			startActivityForResult(intent2,21);
			break;
		case R.id.team_city:
//			Intent intent5 = new Intent();
//			intent5.setClass(mContext, CityChooseActivity.class);
//			startActivityForResult(intent5, 24);
            showSelectCityDialog();
			break;
		case R.id.team_found:
			showTimeDialog(mContext,getDateView());
			break;
		case R.id.team_register:
			Intent intent3 = new Intent();
			intent3.setClass(mContext, InputActivity.class);
			intent3.putExtra("input_type", 2);
			startActivityForResult(intent3,22);
			break;
		case R.id.team_intro:
			Intent intent4 = new Intent();
			intent4.setClass(mContext, InputActivity.class);
			intent4.putExtra("input_type", 3);
			startActivityForResult(intent4,23);
			break;
		case R.id.take_pic:
			takePhoto();
			cancelDialog();
			break;
		case R.id.choose_from_album:
			getAlbumn();
			cancelDialog();
			break;
		case R.id.choose_cancel:
			cancelDialog();
			break;
		default:
			break;
		}
	}
	
	
	Dialog timeDialog = null;
	private void showTimeDialog(Context context,View view){
		if(timeDialog == null){
			timeDialog = new AlertDialog.Builder(context).create();
		}
		timeDialog.show();
		timeDialog.setCanceledOnTouchOutside(false);
		timeDialog.setContentView(view);
		timeDialog.getWindow().setGravity(Gravity.CENTER);
		timeDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth()-30,
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
	}
	
	
	/**
	 * 处理日期选择
	 * @return
	 */
	private View getDateView() {
		View view = LayoutInflater.from(TeamDetailActivity.this).inflate(
				R.layout.dialog_date_picker, null);
		TextView title = (TextView)view.findViewById(R.id.picker_title);
		title.setText("选择日期");
		final DatePicker datePicker = (DatePicker)view.findViewById(R.id.datePicker);
		datePicker.setYearMin(Integer.parseInt(TimeUtils.getCurrentYear()));
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
				Date comDate = mCalendar.getTime();
				teamDate = new BmobDate(mCalendar.getTime());
				teamFoundTime.setText(TimeUtils.getCurrentYear(teamDate));
//				birthContent.setText(new BmobDate(mCalendar.getTime()).getDate().substring(0, 10));
				if(timeDialog!=null&&timeDialog.isShowing()){
					timeDialog.dismiss();
				}
			}
		});
		return view;
	}

    /**
     * 打开城市选择对话框
     */
    private void showSelectCityDialog(){
        final Dialog timeDialog = new AlertDialog.Builder(this).create();
        View view = LayoutInflater.from(this).inflate(
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
                teamCityView.setText(cityPicker.getCity_string());
                cityName = cityPicker.getCity_string();
                teamCity = cityPicker.getCity_code();
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
	
	private void getAlbumn() {
		// TODO Auto-generated method stub
		Intent intent = new Intent(Intent.ACTION_PICK, null);
		intent.setDataAndType(
				MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
		startActivityForResult(intent,
				Constant.REQUESTCODE_UPLOADAVATAR_LOCATION);
	}
	
    private void cancelDialog(){
    	if(mDialog!=null&&mDialog.isShowing()){
    		mDialog.dismiss();
    	}
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
	
	private void showLogoDialog(){
		if(mDialog == null){
			mDialog = new AlertDialog.Builder(TeamDetailActivity.this).create();
		}
		mDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(TeamDetailActivity.this).inflate(
				R.layout.dialog_choose_logo, null);
		mDialog.show();
		mDialog.setContentView(view);
		mDialog.getWindow().setGravity(Gravity.BOTTOM);
		mDialog.getWindow().setLayout(
				getWindowManager().getDefaultDisplay().getWidth(),
				android.view.WindowManager.LayoutParams.WRAP_CONTENT);
		
		Button takePick = (Button)view.findViewById(R.id.take_pic);
		Button chooseAlbumn = (Button)view.findViewById(R.id.choose_from_album);
		Button cancelChoose = (Button)view.findViewById(R.id.choose_cancel);
		takePick.setOnClickListener(this);
		chooseAlbumn.setOnClickListener(this);
		cancelChoose.setOnClickListener(this);
	}
	
	
	@Override
	protected void onLeftMenuClick() {
		super.onLeftMenuClick();
		finish();
	}
	
	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
		if(TextUtils.isEmpty(path)){
			createTeam(null,currentTeam);
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
//					refreshAvatar(avatorUrl);
					//更新BmobUser对象
					updateUserAvatar(bmobFile);
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
	
	/**
	 * 检查是否已存在球队名，如果存在则要求更改
	 * @param url
	 */
	private void updateUserAvatar(final BmobFile url){
		if(teamName==null){
			createTeam(url,currentTeam);
		}else{
			BmobQuery<Team> teamQuery = new BmobQuery<Team>();
			teamQuery.addWhereEqualTo("name", teamName);
			teamQuery.findObjects(mContext, new FindListener<Team>() {
				
				@Override
				public void onSuccess(List<Team> arg0) {
					// TODO Auto-generated method stub
					if(arg0.size()==0){
						createTeam(url,currentTeam);
					}else{
						showToast("已存在此球队，请更改球队名字。");
					}
				}
				
				@Override
				public void onError(int arg0, String arg1) {
					// TODO Auto-generated method stub
					showToast("创建球队失败，请检查网络连接。");
				}
			});
		}
	}
	
	
	private void createTeam(BmobFile url,Team team) {
		if(teamName!=null)
			team.setName(teamName);
		if(teamCity!=null){
			team.setCity(teamCity);
			team.setCityname(cityName);
		}
		if(teamDate!=null)
			team.setFound_time(teamDate);
		if(!TextUtils.isEmpty(registerCode)){
			team.setGsl_code(registerCode);
		}
		if(!TextUtils.isEmpty(intro)){
			team.setAbout(intro);
		}
		
		if(captain!=null){
			team.setCaptain(captain);
			
		}
		if(url!=null)
			team.setAvator(url);
		team.update(this, new UpdateListener() {
		    @Override
		    public void onSuccess() {
		        // TODO Auto-generated method stub
		    	showToast("更新信息成功！");
		    	setResult(RESULT_OK);
		    	finish();
		    }
		    @Override
		    public void onFailure(int code, String msg) {
		        // TODO Auto-generated method stub
		    	showToast("更新信息失败："+code+msg);
		    	LogUtil.i("avator","更新信息失败："+code+msg);
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
			case 11:
				if(resultCode==RESULT_OK){
					Bundle bundle = data.getExtras();
					captain = (User) bundle.getSerializable("user");
					if(captain!=null){
						if(captain.getNickname()!=null){
							teamCaptainName.setText(captain.getNickname());
						}else{
							teamCaptainName.setText(captain.getUsername());
						}
					}
				}
				break;
			case Constant.REQUESTCODE_UPLOADAVATAR_CAMERA:// 拍照修改头像
				if (resultCode == RESULT_OK) {
					if (!Environment.getExternalStorageState().equals(
							Environment.MEDIA_MOUNTED)) {
						showToast("SD不可用");
						return;
					}
					isFromCamera = true;
					File file = new File(filePath);
					
					startImageAction(Uri.fromFile(file), 400, 300,
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
//					uploadAvatar();
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
//						Bitmap bit = BitmapFactory.decodeResource(getResources(), R.drawable.team_logo_default);
//						int width = bit.getWidth();
//						int height = bit.getHeight();
						startImageAction(uri, 400, 300,
								Constant.REQUESTCODE_UPLOADAVATAR_CROP, true);
//						if(bit!=null&&!bit.isRecycled()){
//							bit.recycle();
//						}
					} else {
						showToast("照片获取失败");
					}

					break;
				case 21:
					if(resultCode == RESULT_OK){
						Bundle bundle = data.getExtras();
						teamName = bundle.getString("data");
						if(teamName.equals(currentTeam.getName())){
							return;
						}
						if(teamName!=null){
							teamNameInput.setText(teamName);
						}
					}
					break;
				case 22:
					if(resultCode == RESULT_OK){
						Bundle bundle = data.getExtras();
						registerCode = bundle.getString("data");
						if(registerCode!=null){
							registerCodeInput.setText(registerCode);
						}
					}
					break;
				case 23:
					if(resultCode == RESULT_OK){
						Bundle bundle = data.getExtras();
						intro = bundle.getString("data");
						if(intro!=null){
							teamIntroInput.setText(intro);
						}
					}
					break;
				case 24:
					if (resultCode == RESULT_OK) {
						Bundle bundle = data.getExtras();
						City city = (City) bundle.getSerializable("city");
//						showToast(city.getCity_name());
						teamCityView.setText(city.getCity_name());
						teamCity = city.getCityId();
						cityName = city.getCity_name();
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
		intent.putExtra("aspectX", 4);
		intent.putExtra("aspectY", 3);
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
				
				teamLogo.setImageBitmap(bitmap);
				// 保存图片
				String filename = new SimpleDateFormat("yyMMddHHmmss")
						.format(new Date())+".png";
				path = Constant.BMOB_AVATAR_DIR + filename;
				PhotoUtil.saveBitmap(Constant.BMOB_AVATAR_DIR, filename,
						bitmap, true);
				// 上传头像
				if (bitmap != null && bitmap.isRecycled()) {
					bitmap.recycle();
				}
			}
		}
	}
	
}
