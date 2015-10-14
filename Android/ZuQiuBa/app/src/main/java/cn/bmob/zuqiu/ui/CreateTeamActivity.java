package cn.bmob.zuqiu.ui;

import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.Editable;
import android.text.Selection;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import cn.bmob.v3.AsyncCustomEndpoints;
import cn.bmob.v3.BmobInstallation;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.datatype.BmobDate;
import cn.bmob.v3.datatype.BmobFile;
import cn.bmob.v3.datatype.BmobRelation;
import cn.bmob.v3.listener.CloudCodeListener;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.v3.listener.SaveListener;
import cn.bmob.v3.listener.UpdateListener;
import cn.bmob.v3.listener.UploadFileListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiu.utils.Constant;
import cn.bmob.zuqiu.utils.ImageLoadOptions;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiu.utils.PhotoUtil;
import cn.bmob.zuqiu.utils.TeamManager;
import cn.bmob.zuqiuj.bean.City;
import cn.bmob.zuqiuj.bean.MyInstallation;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.User;

public class CreateTeamActivity extends BaseActivity{

	ImageView teamLogo;
	
	RelativeLayout teamNameLayout;
	EditText teamNameInput;
	
	RelativeLayout teamCityLayout;
	TextView teamCityView;
	
	RelativeLayout teamFoundTimeLayout;
	TextView teamFoundTime;
	
	RelativeLayout registerLayout;
	EditText registerCodeInput;
	
	RelativeLayout changeCaptain;
	RelativeLayout teamIntroduce;
	EditText teamIntroInput;
	
	private AlertDialog mDialog;
	
	String teamName;
	String teamCity;
	String cityName;
	String registerCode;
	String teamIntro;
	
	
	public static final int GET_CITY = 5;
	@Override
	protected void onCreate(Bundle bundle) {
		// TODO Auto-generated method stub
		super.onCreate(bundle);
		setViewContent(R.layout.activity_info_team);
		setUpAction(mActionBarTitle, getString(R.string.team_create), 0, View.VISIBLE);
		setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
		setUpAction(mActionBarRightMenu, "", R.drawable.commit_actionbar, View.VISIBLE);
		
//		teamFoundTime.setText(TimeUtils.getCurrentYear()+"年");
		teamFoundTime.setText(new BmobDate(new Date()).getDate());
	}
	
	@Override
	protected void findViews(View contentView) {
		// TODO Auto-generated method stub
		teamLogo = (ImageView)contentView.findViewById(R.id.team_logo);
		teamNameLayout = (RelativeLayout)contentView.findViewById(R.id.team_name);
		teamNameInput = (EditText)contentView.findViewById(R.id.team_name_content);
		
		teamCityLayout = (RelativeLayout)contentView.findViewById(R.id.team_city);
		teamCityView = (TextView)contentView.findViewById(R.id.team_city_content);
		
		teamFoundTimeLayout = (RelativeLayout)contentView.findViewById(R.id.team_found);
		teamFoundTime = (TextView)contentView.findViewById(R.id.team_found_content);
		
		registerLayout = (RelativeLayout)contentView.findViewById(R.id.team_register);
		registerCodeInput = (EditText)contentView.findViewById(R.id.team_regsiter_content);
		
		changeCaptain = (RelativeLayout)contentView.findViewById(R.id.team_change);
		teamIntroduce = (RelativeLayout)contentView.findViewById(R.id.team_intro);
		teamIntroInput = (EditText)contentView.findViewById(R.id.team_intro_content);
		
		setListenter();
	}

	protected void setListenter() {
		// TODO Auto-generated method stub
		teamLogo.setOnClickListener(this);
		teamNameLayout.setOnClickListener(this);
		teamCityLayout.setOnClickListener(this);
		teamFoundTimeLayout.setOnClickListener(this);
		registerLayout.setOnClickListener(this);
		changeCaptain.setOnClickListener(this);
		teamIntroduce.setOnClickListener(this);
		
		teamNameInput.addTextChangedListener(new TextWatcher() {
			private CharSequence temp;
	        private int editStart ;
	        private int editEnd ;
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
				temp = s;
			}
			
			
			@Override
			public void afterTextChanged(Editable s) {
				// TODO Auto-generated method stub
				 editStart = teamNameInput.getSelectionStart();
		            editEnd = teamNameInput.getSelectionEnd();
		            if (temp.length() > 10) {
		                showToast("你输入的字数已经超过了10个字！");
		                s.delete(editStart-1, editEnd);
		                int tempSelection = editStart;
		                teamNameInput.setText(s);
//		                teamNameInput.setSelection(editEnd);
		                Selection.setSelection(s, s.length());
		            }
			}
		});
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.team_logo:
			showLogoDialog();
			break;
		case R.id.team_name:
			
			break;
		case R.id.team_city:
//			redictTo(mContext, CityChooseActivity.class, null);
			Intent intent = new Intent();
			intent.setClass(mContext, CityChooseActivity.class);
			startActivityForResult(intent, GET_CITY);
			break;
		case R.id.team_found:
			
			break;
		case R.id.team_register:
			
			break;
		case R.id.team_change:
			
			break;
		case R.id.team_intro:
			
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

	private void showLogoDialog(){
		if(mDialog == null){
			mDialog = new AlertDialog.Builder(CreateTeamActivity.this).create();
		}
		mDialog.setCanceledOnTouchOutside(false);

		View view = LayoutInflater.from(CreateTeamActivity.this).inflate(
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
	
    private void cancelDialog(){
    	if(mDialog!=null&&mDialog.isShowing()){
    		mDialog.dismiss();
    	}
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
		teamName = teamNameInput.getText().toString().trim();
		if(TextUtils.isEmpty(teamName)){
			showToast("球队名不能为空");
			return;
		}
		if(TextUtils.isEmpty(teamCity)){
			showToast("请选择城市");
			return;
		}
		registerCode = registerCodeInput.getText().toString().trim();
		teamIntro = teamIntroInput.getText().toString().trim();
		uploadAvatar(path);
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
			case GET_CITY:
				if (resultCode == RESULT_OK) {
					Bundle bundle = data.getExtras();
					City city = (City) bundle.getSerializable("city");
//					showToast(city.getCity_name());
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
				
				teamLogo.setImageBitmap(bitmap);
				// 保存图片
				String filename = new SimpleDateFormat("yyMMddHHmmss")
						.format(new Date())+".jpg";
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
	
	private void uploadAvatar(String path){
		if(TextUtils.isEmpty(path)){
//			showToast("你尚未设置头像");
            updateUserAvatar(null);
			return;
		}
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
	
	/**
	 * 检查是否已存在球队名，如果存在则要求更改
	 * @param url
	 */
	private void updateUserAvatar(final BmobFile url){
		
		BmobQuery<Team> teamQuery = new BmobQuery<Team>();
		teamQuery.addWhereEqualTo("name", teamName);
		teamQuery.findObjects(mContext, new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> arg0) {
				// TODO Auto-generated method stub
				if(arg0.size()==0){
					createTeam(url);
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

	private void createTeam(BmobFile url) {
		final Team team = new Team();
		team.setName(teamName);
		team.setCity(teamCity);
		team.setCityname(cityName);
		team.setFound_time(new BmobDate(new Date()));
		if(!TextUtils.isEmpty(registerCode)){
			team.setGsl_code(registerCode);
		}
		if(!TextUtils.isEmpty(teamIntro)){
			team.setAbout(teamIntro);
		}
		final User user = BmobUser.getCurrentUser(mContext, User.class);
		if(user!=null){
			team.setCaptain(user);
			BmobRelation b = new BmobRelation();
			b.add(user);
			team.setFootballer(b);
		}
        if(url != null){
            team.setAvator(url);
        }
        // 设置各字段的默认值
        team.setAppearances(0);
        team.setWin(0);
        team.setDraw(0);
        team.setLoss(0);
        team.setGoals(0);
        team.setGoals_against(0);
        team.setGoal_difference(0);
        team.setAppearancesTotal(0);
        team.setDrawTotal(0);
        team.setGoalsTotal(0);
        team.setGoalsAgainstTotal(0);
        team.setLossTotal(0);
        team.setGoalDifferenceTotal(0);
        team.setWinTotal(0);

		team.save(this, new SaveListener() {
		    @Override
		    public void onSuccess() {
		        // TODO Auto-generated method stub
		    	showToast("创建球队成功！");
				BmobQuery<MyInstallation> query = new BmobQuery<MyInstallation>();
				query.addWhereEqualTo("installationId", BmobInstallation.getCurrentInstallation(mContext).getInstallationId());
				query.order("-updatedAt");
				query.findObjects(mContext, new FindListener<MyInstallation>() {

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
						
					}

					@Override
					public void onSuccess(List<MyInstallation> arg0) {
						// TODO Auto-generated method stub
						if(arg0.size()!=0){
							MyInstallation install = arg0.get(0);
							install.subscribe(team.getObjectId());
							install.update(mContext, new UpdateListener() {
								
								@Override
								public void onSuccess() {
									// TODO Auto-generated method stub
									LogUtil.i("push","订阅球队信息成功。");
								}
								
								@Override
								public void onFailure(int arg0, String arg1) {
									// TODO Auto-generated method stub
									LogUtil.i("push","订阅球队信息失败。"+arg0+arg1);
								}
							});
						}

                        // 填充球队邀请码
                        AsyncCustomEndpoints ace = new AsyncCustomEndpoints();
                        JSONObject params = new JSONObject();
                        try {
                            params.put("teamId", team.getObjectId());
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }

                        ace.callEndpoint(mContext, "genTeamRegCode", params, new CloudCodeListener() {
                            @Override
                            public void onSuccess(Object o) {

                            }

                            @Override
                            public void onFailure(int i, String s) {

                            }
                        });
					}
				});
		    	TeamManager.getMyTeams(mContext, new FindListener<Team>() {

					@Override
					public void onError(int arg0, String arg1) {
						// TODO Auto-generated method stub
						LogUtil.i(TAG,"getTeam failed."+arg0+arg1);
					}

					@Override
					public void onSuccess(List<Team> arg0) {
						// TODO Auto-generated method stub
						MyApplication.getInstance().setTeams(arg0);
					}
				});
		    	
		    	finish();
		    }
		    @Override
		    public void onFailure(int code, String msg) {
		        // TODO Auto-generated method stub
		    	showToast("创建球队失败："+code+msg);
		    	LogUtil.i("avator","创建球队失败："+code+msg);
		    }
		});
	}
	
	/** 更新头像
	  * refreshAvatar
	  * @return void
	  * @throws
	  */
	private void refreshAvatar(String avator){
		if (avator != null && !avator.equals("")) {
			ImageLoader.getInstance().displayImage(avator, teamLogo, ImageLoadOptions.getOptions(R.drawable.team_logo_default,0));
		} else {
			teamLogo.setImageResource(R.drawable.team_logo_default);
		}
	}
}
