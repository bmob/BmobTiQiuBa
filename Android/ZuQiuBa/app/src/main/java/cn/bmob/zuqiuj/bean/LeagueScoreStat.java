package cn.bmob.zuqiuj.bean;

import android.text.TextUtils;

import net.sourceforge.pinyin4j.PinyinHelper;
import net.sourceforge.pinyin4j.format.HanyuPinyinCaseType;
import net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat;
import net.sourceforge.pinyin4j.format.HanyuPinyinToneType;
import net.sourceforge.pinyin4j.format.HanyuPinyinVCharType;

import cn.bmob.v3.BmobObject;

public class LeagueScoreStat extends BmobObject implements Comparable<LeagueScoreStat>{
    private Integer index;//排名
    private String groupName;//组名
    private League league;
    private Team team;
    private String teamName;
    private Integer win;
    private Integer draw;
    private Integer loss;
    private Integer goals;
    private Integer goalsAgainst;
    private Integer goalDifference;
    private Integer points;

    public Integer getIndex() {
        return index;
    }

    public void setIndex(Integer index) {
        this.index = index;
    }

    public League getLeague() {
        return league;
    }

    public void setLeague(League league) {
        this.league = league;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public Integer getWin() {
        return win;
    }

    public void setWin(Integer win) {
        this.win = win;
    }

    public Integer getDraw() {
        return draw;
    }

    public void setDraw(Integer draw) {
        this.draw = draw;
    }

    public Integer getLoss() {
        return loss;
    }

    public void setLoss(Integer loss) {
        this.loss = loss;
    }

    public Integer getGoals() {
        return goals;
    }

    public void setGoals(Integer goals) {
        this.goals = goals;
    }

    public Integer getGoalsAgainst() {
        return goalsAgainst;
    }

    public void setGoalsAgainst(Integer goalsAgainst) {
        this.goalsAgainst = goalsAgainst;
    }

    public Integer getGoalDifference() {
        return goalDifference;
    }

    public void setGoalDifference(Integer goalDifference) {
        this.goalDifference = goalDifference;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    @Override
    public int compareTo(LeagueScoreStat another) {
        String regex = "^\\w.*";
        if(!TextUtils.isEmpty(this.getGroupName())&& !TextUtils.isEmpty(another.getGroupName())){
            if (this.getGroupName().matches(regex) || another.getGroupName().matches(regex)) {
                return this.getGroupName().compareTo(another.getGroupName());
            } else {
                return genPinYin(this.getGroupName()).compareTo(genPinYin(another.getGroupName()));
            }
        }else{
            return -1;
        }
    }

    /*
    * 未使用
    * */
    public static String genPinYin(String input) {
        if (input == null || input.trim().equals("")) {
            return "";
        }
        HanyuPinyinOutputFormat format = new HanyuPinyinOutputFormat();
        format.setCaseType(HanyuPinyinCaseType.LOWERCASE);
        format.setToneType(HanyuPinyinToneType.WITHOUT_TONE);
        format.setVCharType(HanyuPinyinVCharType.WITH_V);
        //多音字预先转换 这里可以处理一下多音字
        char[] chars =  input.trim().toCharArray();
        StringBuilder output = new StringBuilder();
        try {
            for (char c : chars) {
                if (Character.toString(c).matches("[\\u4E00-\\u9FA5]+")) {
                    String[] temp = PinyinHelper.toHanyuPinyinStringArray(c, format);
                    output.append(temp[0]);
                } else {
                    output.append(Character.toString(c));
                }
            }
        } catch (Exception e) {
            System.err.println("拼音转换出现未知异常：" + input);
        }
        return output.toString();
    }
}
