package cn.bmob.zuqiu.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.RelativeLayout;
import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.NearbyTeamAdapter;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.ToastUtil;
import cn.bmob.zuqiuj.bean.Team;


public class CreateOrSearchcTeamFragment extends BaseFragment{

	RelativeLayout createTeam;
	ImageButton searchTeam;
	EditText teamInput;
	ListView nearTeamList;
	NearbyTeamAdapter mAdapter;
	String searchContent;
	List<Team> dataList = new ArrayList<Team>();
    @Override
    public void onAttach(Activity activity) {
        // TODO Auto-generated method stub
        super.onAttach(activity);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        View v = inflater.inflate(R.layout.fragment_create_or_search, container, false);
        return v;
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        // TODO Auto-generated method stub
        super.onHiddenChanged(hidden);
    }

    @Override
    public void onPause() {
        // TODO Auto-generated method stub
        super.onPause();
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onViewCreated(view, savedInstanceState);
        setUpTitle(getString(R.string.main_menu_add_team));
        view.findViewById(R.id.fragment_actionbar).setVisibility(View.GONE);
        createTeam = (RelativeLayout)view.findViewById(R.id.team_create);
        searchTeam = (ImageButton)view.findViewById(R.id.search_team);
        teamInput = (EditText)view.findViewById(R.id.search_team_input);
        nearTeamList = (ListView)view.findViewById(R.id.nearby_team_list);
        nearTeamList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				Bundle bundle = new Bundle();
				bundle.putSerializable("team", dataList.get(position));
				Intent intent = new Intent();
				intent.setClass(getActivity(), OtherTeamInfoActivity.class);
				intent.putExtra("data", bundle);
				startActivity(intent);
			}
		});
        createTeam.setOnClickListener(this);
        searchTeam.setOnClickListener(this);
    
        queryNearbyTeams(null,null);
        
    }

    
    private void queryNearbyTeams(String[] keys,String[] values) {
		// TODO Auto-generated method stub
		BmobQuery<Team> teamQuery = new BmobQuery<Team>();
		teamQuery.include("captain");
		if(keys!=null&&values!=null){
			for(int i=0;i<keys.length;i++){
				teamQuery.addWhereContains(keys[i], values[i]);
			}
		}
		showToast("正在搜索球队...");
		teamQuery.findObjects(getActivity(), new FindListener<Team>() {
			
			@Override
			public void onSuccess(List<Team> data) {
				// TODO Auto-generated method stub
				if(data.size()!=0){
					dataList = data;
					if(mAdapter == null){
						mAdapter = new NearbyTeamAdapter(getActivity(), data);
						nearTeamList.setAdapter(mAdapter);
					}else{
						mAdapter.setTeams(data);
						mAdapter.notifyDataSetChanged();
					}
//					ToastUtil.showToast(getActivity(), "找到"+data.size()+"支球队。");
				}else{
					ToastUtil.showToast(getActivity(), "没有找到你要找的球队。");
				}
			}
			
			@Override
			public void onError(int errorCode, String errorString) {
				// TODO Auto-generated method stub
				
			}
		});
	}

	@Override
    public void onClick(View v) {
    	// TODO Auto-generated method stub
    	super.onClick(v);
    	switch (v.getId()) {
		case R.id.search_team:
			searchContent = teamInput.getText().toString().trim();
			if(TextUtils.isEmpty(searchContent)){
				ToastUtil.showToast(getActivity(),getString(R.string.search_input_tips));
				return;
			}
			Intent intent = new Intent();
			intent.setClass(getActivity(), SearchTeamActivity.class);
			intent.putExtra("search_content", searchContent);
			startActivity(intent);
			hideSoftInput();
			break;
		case R.id.team_create:
			if(MyApplication.getInstance().getTeams().size()==2){
				showToast("您只能加入两支球队，请退出一支后再创建球队。");
				return;
			}
			Intent intent1 = new Intent();
			intent1.setClass(getActivity(), CreateTeamActivity.class);
			getActivity().startActivity(intent1);
			break;
		default:
			break;
		}
    }
	
	private void hideSoftInput(){
		InputMethodManager imm = (InputMethodManager)getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);  

		imm.hideSoftInputFromWindow(teamInput.getWindowToken(), 0);
	}
	
}
