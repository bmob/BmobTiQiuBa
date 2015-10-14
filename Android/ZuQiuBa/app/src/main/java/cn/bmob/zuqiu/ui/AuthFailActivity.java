package cn.bmob.zuqiu.ui;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.listener.GetListener;
import cn.bmob.zuqiu.R;
import cn.bmob.zuqiu.ui.base.BaseActivity;
import cn.bmob.zuqiuj.bean.Tournament;

/**
 * 认证失败
 */
public class AuthFailActivity extends BaseActivity{
    TextView tv_zddz, tv_kddz, tv_zdbf, tv_kdbf;
    Button btn_updateData;
    String tournamentId;//比赛id
    Tournament mTournament;

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setViewContent(R.layout.activity_authfail);
        setUpAction(mActionBarTitle, "认证失败", 0, View.VISIBLE);
        setUpAction(mActionBarLeftMenu, "", R.drawable.back_actionbar, View.VISIBLE);
    }

    @Override
    protected void findViews(View contentView) {
        tv_zddz = (TextView) findViewById(R.id.tv_zddz);
        tv_kddz = (TextView) findViewById(R.id.tv_kddz);
        tv_zdbf = (TextView) findViewById(R.id.tv_zdbf);
        tv_kdbf = (TextView) findViewById(R.id.tv_kdbf);
        btn_updateData = (Button) findViewById(R.id.btn_updateData);
        btn_updateData.setOnClickListener(this);
        tournamentId = getIntent().getStringExtra("tournamentId");
        getScoreData();
    }

    @Override
    protected void onLeftMenuClick() {
        // TODO Auto-generated method stub
        super.onLeftMenuClick();
        finish();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        if(v.getId() == R.id.btn_updateData){
            if(mTournament == null){
                showToast("暂无该场比赛的比分数据");
                return;
            }
            Intent intent = new Intent();
            intent.setClass(mContext, CompetitionInfoActivity.class);
            intent.putExtra("tournament", mTournament);
            startActivity(intent);
            finish();
        }
    }

    private void getScoreData(){
        initProgressDialog("正在获取比分...");
        BmobQuery<Tournament> query = new BmobQuery<Tournament>();
        query.include("home_court,opponent,league");
        query.getObject(this, tournamentId, new GetListener<Tournament>() {
            @Override
            public void onSuccess(Tournament tournament) {
                dismissDialog();;
                if (tournament != null) {
                    mTournament = tournament;
                    tv_zddz.setText(tournament.getHome_court().getName());
                    tv_kddz.setText(tournament.getOpponent().getName());
                    String zdz = TextUtils.isEmpty(tournament.getScore_h()) ? "0" : tournament.getScore_h();
                    String zdk = TextUtils.isEmpty(tournament.getScore_h2()) ? "0" : tournament.getScore_h2();
                    String kdz = TextUtils.isEmpty(tournament.getScore_o2()) ? "0" : tournament.getScore_o2();
                    String kdk = TextUtils.isEmpty(tournament.getScore_o()) ? "0" : tournament.getScore_o();
                    tv_zdbf.setText(zdz + " - " + zdk);
                    tv_kdbf.setText(kdz + " - " + kdk);
                }
            }

            @Override
            public void onFailure(int i, String s) {
                dismissDialog();;
                showToast("获取比分失败" );
            }
        });
    }
}
