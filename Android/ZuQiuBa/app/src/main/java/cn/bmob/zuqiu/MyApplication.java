package cn.bmob.zuqiu;

import android.content.Context;

import com.baidu.frontia.FrontiaApplication;
import com.nostra13.universalimageloader.cache.disc.naming.Md5FileNameGenerator;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.zuqiu.utils.PushHelper2;
import cn.bmob.zuqiuj.bean.League;
import cn.bmob.zuqiuj.bean.Team;
import cn.bmob.zuqiuj.bean.Tournament;
import cn.bmob.zuqiuj.bean.User;


public class MyApplication extends FrontiaApplication {

	private static MyApplication mApplication;
	private List<Team> teams = new ArrayList<Team>();
	private List<User> friends = new ArrayList<User>();
	private Tournament mTournament;//记录正在创建的比赛信息
    private PushHelper2 pushHelper2;
	private Team currentTeam;
	private League currentLeague;
	private List<User> teamMember = new ArrayList<User>();
	
	
	public List<User> getTeamMember() {
		return teamMember;
	}

	public void setTeamMember(List<User> teamMember) {
		this.teamMember = teamMember;
	}

	public League getCurrentLeague() {
		return currentLeague;
	}

	public void setCurrentLeague(League currentLeague) {
		this.currentLeague = currentLeague;
	}

	public Team getCurrentTeam() {
		return currentTeam;
	}

	public void setCurrentTeam(Team currentTeam) {
		this.currentTeam = currentTeam;
	}

	public List<User> getFriends() {
		return friends;
	}

	public void setFriends(List<User> friends) {
		this.friends = friends;
	}

	public Tournament getmTournament() {
		if(mTournament ==null){
			mTournament = new Tournament();
		}
		return mTournament;
	}

	public void setmTournament(Tournament mTournament) {
		this.mTournament = mTournament;
	}

	public List<Team> getTeams() {
		return teams;
	}

	public void setTeams(List<Team> teams) {
        if(this.teams!=null){//先清除之前存储的数据
            this.teams.clear();
        }
		this.teams = teams;
	}

	public static MyApplication getInstance(){
		return mApplication;
	}

    /*
    * 退出登陆的时候需要清空内存数据
    * */
    public void clearCache(){
        getTeams().clear();
        getFriends().clear();
        getTeamMember().clear();
        currentTeam = null;
        currentLeague = null;
        mTournament =null;
    }

	@Override
    public void onCreate() {
        // TODO Auto-generated method stub
        super.onCreate();
        mApplication = this;
        initImageLoader(getApplicationContext());
    }

    public PushHelper2 getPushHelper2(){
        if(pushHelper2 == null){
            pushHelper2 = new PushHelper2(getApplicationContext());
        }
        return pushHelper2;
    }
    
	public static void initImageLoader(Context context) {
		ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(context)
				.threadPriority(Thread.NORM_PRIORITY - 2)
				.denyCacheImageMultipleSizesInMemory()
				.diskCacheFileNameGenerator(new Md5FileNameGenerator())
				.diskCacheSize(50 * 1024 * 1024) // 50 Mb
				.tasksProcessingOrder(QueueProcessingType.LIFO)
				.writeDebugLogs() // Remove for release app
				.build();
		// Initialize ImageLoader with configuration.
		ImageLoader.getInstance().init(config);
	}
}
