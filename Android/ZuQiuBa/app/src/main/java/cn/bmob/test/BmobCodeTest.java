package cn.bmob.test;

import android.test.InstrumentationTestCase;

import java.util.List;

import cn.bmob.v3.BmobQuery;
import cn.bmob.v3.datatype.BmobPointer;
import cn.bmob.v3.datatype.BmobRelation;
import cn.bmob.v3.listener.FindListener;
import cn.bmob.zuqiu.MyApplication;
import cn.bmob.zuqiu.utils.LogUtil;
import cn.bmob.zuqiuj.bean.Group;
import cn.bmob.zuqiuj.bean.League;

public class BmobCodeTest extends InstrumentationTestCase{

    public void testGetLeagueGroup(){
        League league = new League();
        league.setObjectId("830f781f21");
        BmobQuery<Group> query = new BmobQuery<Group>();
        query.addWhereEqualTo("league", league);
        query.findObjects(MyApplication.getInstance(), new FindListener<Group>() {
            @Override
            public void onSuccess(List<Group> groups) {
                if(groups.size()>0){
                    for (Group group: groups){
                        if(group.getTeams() != null){
                            BmobRelation br = group.getTeams();
                            LogUtil.d("bmob", "*****  " + br.toString());
                            if(br.getObjects() != null){
                                for (BmobPointer bp : br.getObjects()){
                                    LogUtil.d("bmob", "*****  " + bp.toString());
                                }
                            }
                        }
                    }
                }
            }

            @Override
            public void onError(int i, String s) {

            }
        });
    }
}
