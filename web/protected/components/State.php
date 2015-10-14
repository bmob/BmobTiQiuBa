<?php
/**
 * @desc ajax 返回状态码
 * 1000 正常       1001-1999 系统错误
 */

class State{

     public static $SUSSION_CODE = 1000;
     public static $SUSSION_MSG = '成功';
     
     public static $SYS_ERROR_CODE = 1001;
     public static $SYS_ERROR_MSG = '系统太忙了，请稍后再试';
     
     public static $SYS_NOT_LOGIN_CODE = 1002;
     public static $SYS_NOT_LOGIN_MSG = '您还没有登录， 不能进行此操作';
     
     public static $SYS_PARAM_ERROR_CODE = 1003;
     public static $SYS_PARAM_ERROR_MSG = '参数错误';
     
     public static $SYS_PERMISSION_ERROR_CODE = 1004;
     public static $SYS_PERMISSION_ERROR_MSG = '权限错误';

	 public static $TEAM_DELETE_ERROR_CODE = 2001;
	 public static $TEAM_DELETE_ERROR_MSG = '分组已完成，无法删除联赛球队！';
	public static $TEAM_ADD_ERROR_CODE = 2002;
	public static $TEAM_ADD_ERROR_MSG = '分组已完成，无法添加联赛球队！';

	public static $TEAM_SENDMSG_ERROR_CODE = 3001;
	public static $TEAM_SENDMSG_ERROR_MSG = '必须填写球队名称，和正确的手机号！';

	public static $LEAGUE_RANGE_ERROR_CODE = 3101;
	public static $LEAGUE_RANGE_ERROR_MSG = '联赛排行榜数据更新失败！';

	public static $SHOOTER_RANGE_ERROR_CODE = 3102;
	public static $SHOOTER_RANGE_ERROR_MSG = '射手榜单更新失败！';

}