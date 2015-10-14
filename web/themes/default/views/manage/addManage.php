<style>
	body{background: #ffffff;}
	.sidebar-p{padding: 20px;background: #f3f5f9;}
	.sidebar-p .team-list{background: #ffffff;border: 1px solid #cfd0d4;}
	.sidebar-p .team-list li{padding: 0px 15px;}
	.sidebar-p .g-name{margin: 20px 0 10px;font-size: 20px;}
</style>
<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>jquery-ui/1.11.1/jquery-ui.min.css" />
<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/jquery-ui-timepicker/jquery-ui-timepicker-addon.min.css" />

<div class="container common-content">
	<div class="row">
		<div class="col-md-9 col-sm-9">
			<div class="main-content">
				<div class="edit-schedule-wrap">
					<div class="block-title clearfix">
						<strong class="pull-left">添加淘汰赛赛程</strong>
						<a class="btn btn-primary pull-right" href="/manage/schedule">查看赛程</a>
					</div>

						<?php
						
						$eventDate = '日期未定';
						$startTime = '时间未定';						
						
						?>
						<div class="edit-schedule-block">
						<ul>
							<li class="clearfix" id="game_schedule_<?php echo $leagueId; ?>">
<!--								<div class="close-btn"><i class="close-circle-btn"></i></div>-->
								<table class="form-horizontal col-md-12 col-sm-12">
									<tr>
										<td class="" colspan="2">
											<div class="">
												<div class="btn btn-info">
													<select class="form-control game-home-court">
														<?php foreach($leagueTeams as $leagueTeam): ?>
															<option value="<?php echo $leagueTeam->objectId?>"><?php echo $leagueTeam->name; ?></option>
														<?php endforeach ?>
													</select>
												</div>
												<i class="vs-icon"></i>
												<div class="btn btn-info">
													<select class="form-control game-opponent">
														<?php foreach($leagueTeams as $leagueTeam): ?>
															<option value="<?php echo $leagueTeam->objectId?>"><?php echo $leagueTeam->name; ?></option>
														<?php endforeach ?>
													</select>											
												</div>
											</div>
											<br/>
										</td>
									</tr>
									<tr>
										<td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">时间：</label>
												<div class="col-sm-9">
													<div class="input-group">
														<input type="text" class="form-control datepicker game-date" value="<?php echo $eventDate; ?>" />
														<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
													</div>
												</div>
											</div>
										</td>
										<td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">地点：</label>
												<div class="col-sm-9">
													<select class="form-control game-address">
														<?php foreach($leagueGrounds as $palyground): ?>
															<option><?php echo $palyground; ?></option>
														<?php endforeach ?>
													</select>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">开始时间：</label>
												<div class="col-sm-9">
													<div class="input-group">
														<input type="text" class="form-control timepicker game-time"
														value="<?php
																	if($startTime != '时间未定'){
																		echo substr($startTime,0,strrpos($startTime,':'));
																	}else{
																		echo $startTime;
																	}
															?>">
														<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
													</div>
												</div>
											</div>
										</td>
										<td style="text-align: right">
											<a class="btn btn-primary save-game-schedule" data-gameid="<?php echo $leagueId; ?>">保存</a>
										</td>
									</tr>

								</table>
							</li>
<!--							<li class="common-full-width-btn">-->
<!--								<i class="fa fa-plus fa-lg color-warning"></i>&nbsp;&nbsp;&nbsp;&nbsp;创建新赛程-->
<!--							</li>-->
						</ul>
					</div>
				</div>
			</div>
		</div>

	</div>
</div>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>jquery-ui/1.11.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/jquery-ui-timepicker/jquery-ui-timepicker-addon.min.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/jquery-ui-timepicker/i18n/jquery-ui-timepicker-zh-CN.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/jquery-ui-timepicker/jquery-ui-sliderAccess.js"></script>

<script type="text/javascript">

	(function(a){

		a(".datepicker").datetimepicker({
			dateFormat: 'yy-mm-dd',
			showTime: false,
			showTimepicker: false,
			regional:"zh-CN"
		});

		a(".timepicker").datetimepicker({
			timeFormat: 'HH:mm',
			timeOnly: true,
			regional:"zh-CN"
		});

		a(".edit-schedule-wrap").delegate('.save-game-schedule','click',function(){
			var leagueId = a(this).data("gameid");
			var _id = a("#game_schedule_"+leagueId);
			var game_date = _id.find(".game-date").val();
			var game_time = _id.find(".game-time").val();
			var game_address = _id.find(".game-address").val();
			
			var home_court_id= _id.find(".game-home-court").val();
			var home_court_name= _id.find(".game-home-court  option:selected").text();
			var opponent_id= _id.find(".game-opponent").val();
			var opponent_name= _id.find(".game-opponent  option:selected").text();			
			
			var dateReg = FBTOOLS.regTest(/^\d{4}-\d{2}-\d{2}$/,game_date);
			var timeReg = FBTOOLS.regTest(/^\d{2}:\d{2}$/,game_time);

			
			
			if(!(dateReg && timeReg)){
				bootbox.alert('请填写正确的日期时间！');
			}else{
				var _this = a(this);
				a.ajax({
					type: 'POST',
					url: FBTOOLS.createUrl('manage/addManageSchedule'),
					data: {'leagueId':leagueId,'game_date':game_date, 'game_time':game_time,'game_address':game_address,'home_court_id':home_court_id,'home_court_name':home_court_name, 'opponent_id':opponent_id,'opponent_name':opponent_name},
					dataType: 'json',
					async: false,
					beforeSend: function () {

					},
					success: function (result) {

						if(!FBTOOLS.checkAjaxResult(result)){
							return;
						}
						if(result.data.response == 'success'){
							bootbox.alert('保存成功！');
						}else{
							bootbox.alert('保存失败！');
						}
						
					}
				});
			}


		});

	})(jQuery)

</script>