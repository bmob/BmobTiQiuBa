package cn.bmob.zuqiu.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.BmobUser;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.adapter.PushMsgAdapter;
import cn.bmob.zuqiu.db.BmobDB;
import cn.bmob.zuqiu.ui.base.BaseFragment;
import cn.bmob.zuqiu.utils.PushMessageHelper;
import cn.bmob.zuqiuj.bean.PushMessage;
import cn.bmob.zuqiuj.bean.PushMsg;
import cn.bmob.zuqiuj.bean.User;

public class MessageFragment extends BaseFragment implements OnRefreshListener {

	private ListView msgList;
	private List<PushMessage> messages = new ArrayList<PushMessage>();
	private PushMsgAdapter mAdapter;
	private SwipeRefreshLayout swipeLayout;

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
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		View v = inflater.inflate(R.layout.fragment_message, container, false);
		return v;
	}

	@Override
	public void onHiddenChanged(boolean hidden) {
		// TODO Auto-generated method stub
		super.onHiddenChanged(hidden);
		if (!hidden) {
            queryUnReadMsg();
		}
	}

    @Override
    public void onPause() {
        // TODO Auto-generated method stub
        super.onPause();
        MobclickAgent.onPageEnd(this.getClass().getSimpleName());
    }

    @Override
    public void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        MobclickAgent.onPageStart(this.getClass().getSimpleName()); //统计页面
    }

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onViewCreated(view, savedInstanceState);
		setUpTitle(getString(R.string.main_menu_message));
		setUpRightMenu("", R.drawable.bg_msg_delete);
		swipeLayout = (SwipeRefreshLayout) this.findViewById(R.id.msg_refresh);
		swipeLayout.setOnRefreshListener(this);
		// 顶部刷新的样式
		swipeLayout.setColorScheme(R.color.red_light, R.color.green_light,
				R.color.blue_bright, R.color.orange_light);
		msgList = (ListView) findViewById(R.id.msg_list);
		messages =BmobDB.create(getActivity()).getAllMessage();
		mAdapter = new PushMsgAdapter(getActivity(), messages);
		msgList.setAdapter(mAdapter);
        msgList.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
                showDeleteDialog(position);
                return false;
            }
        });

	}

    /*
    * 查询属于本人的未读消息
    * */
    public void queryUnReadMsg(){
        swipeLayout.setRefreshing(true);
        User user = BmobUser.getCurrentUser(getActivity(), User.class);
        BmobQuery<PushMsg> query = new BmobQuery<PushMsg>();
        query.addWhereEqualTo("belongUsername",user.getUsername());
        query.addWhereEqualTo("isRead",0);
        query.setLimit(1000);
        query.order("-createdAt");
        query.findObjects(getActivity(),new FindListener<PushMsg>() {
            @Override
            public void onSuccess(List<PushMsg> pushMsgs) {
                if(pushMsgs!=null && pushMsgs.size()>0){
                    int size =pushMsgs.size();
                    for(int i =0;i<size;i++){
                        PushMsg msg = pushMsgs.get(i);
                        //本地数据库
                        PushMessage push = new PushMessage(msg);
                        BmobDB.create(getActivity()).insertMessage(push);
                        PushMessageHelper.resetMsgReaded(getActivity(),msg.getObjectId());
                    }
                }
                notifyUpdate();
            }

            @Override
            public void onError(int i, String s) {
                notifyUpdate();
            }
        });
    }



    /*
    * 更新界面
    * */
    private void notifyUpdate(){
        messages.clear();
        messages = BmobDB.create(getActivity()).getAllMessage();
        mAdapter = new PushMsgAdapter(getActivity(), messages);
        msgList.setAdapter(mAdapter);
        swipeLayout.setRefreshing(false);
    }

    /**
     * 删除消息
     * @param position
     */
    private void showDeleteDialog(final int position){
        new AlertDialog.Builder(getActivity())
                .setMessage("确定删除该条信息吗？")
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        BmobDB.create(getActivity()).deleteMessage(messages.get(position).get_id());
                        messages.remove(position);
                        mAdapter.notifyDataSetChanged();
                    }
                })
                .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                }).create().show();
    }

    /**
     * 删除所有消息
     */
    private void showDeleteAllMessageDialog(){
        new AlertDialog.Builder(getActivity())
                .setMessage("确定清除所有信息吗？")
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        BmobDB.create(getActivity()).deleteAllMessages();
                        messages.clear();
                        mAdapter.notifyDataSetChanged();
                    }
                })
                .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                }).create().show();
    }

	@Override
	protected void onRightMenuClick() {
		// TODO Auto-generated method stub
		super.onRightMenuClick();
        showDeleteAllMessageDialog();
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
        queryUnReadMsg();
	}

}
