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
						<strong class="pull-left">编辑赛程</strong>
						<a class="btn btn-primary pull-right" href="/manage/schedule">查看赛程</a>
					</div>

					<?php foreach($games as $game): ?>
						<?php
						if(!isset($game->event_date->iso)){
							$eventDate = '日期未定';
						}else{
							$dateTime = explode(' ',$game->event_date->iso);
							if(isset($dateTime[0])){
								$eventDate = $dateTime[0];
							}else{
								$eventDate = '日期未定';
							}
						}
						if(!isset($game->start_time->iso)){
							$startTime = '时间未定';
						}else{
							$dateTime = explode(' ',$game->start_time->iso);
							if(isset($dateTime[1])){
								$startTime = $dateTime[1];
							}else{
								$startTime = '日期未定';
							}
						}

						if(!isset($game->home_court->name)){
							$homeCourtName = '主队未知';
						}else{
							$homeCourtName = $game->home_court->name;
						}

						if(!isset($game->opponent->name)){
							$opponentName = '客队未知';
						}else{
							$opponentName = $game->opponent->name;
						}


						if(!isset($game->site)){
							$game->site = '比赛场地未定';
						}
						if(!isset($game->nature)){
							$game->nature = '未定';
						}
						?>
						<div class="edit-schedule-block">
						<ul>
							<li class="clearfix" id="game_schedule_<?php echo $game->objectId; ?>">
<!--								<div class="close-btn"><i class="close-circle-btn"></i></div>-->
								<table class="form-horizontal col-md-12 col-sm-12">
									<tr>
										<td class="" colspan="2">
											<div class="">
												<div class="btn btn-info"><?php echo $homeCourtName; ?></div>
												<i class="vs-icon"></i>
												<div class="btn btn-info"><?php echo $opponentName; ?></div>
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
															<option <?php if($palyground == $game->site){echo 'selected="selected"'; } ?>><?php echo $palyground; ?></option>
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
											<a class="btn btn-primary save-game-schedule" data-gameid="<?php echo $game->objectId; ?>">保存</a>
										</td>
									</tr>

								</table>
							</li>
<!--							<li class="common-full-width-btn">-->
<!--								<i class="fa fa-plus fa-lg color-warning"></i>&nbsp;&nbsp;&nbsp;&nbsp;创建新赛程-->
<!--							</li>-->
						</ul>
					</div>
					<?php endforeach; ?>
				</div>
			</div>
		</div>
		<div class="col-md-3 col-sm-3">
			<?php echo $this->renderPartial('//manage/_sidebar_g',array('groupTeams'=>$groupTeams)); ?>
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
			var gameid = a(this).data("gameid");
			var _id = a("#game_schedule_"+gameid);
			var game_date = _id.find(".game-date").val();
			var game_time = _id.find(".game-time").val();
			var game_address = _id.find(".game-address").val();

			var dateReg = FBTOOLS.regTest(/^\d{4}-\d{2}-\d{2}$/,game_date);
			var timeReg = FBTOOLS.regTest(/^\d{2}:\d{2}$/,game_time);

			if(!(dateReg && timeReg)){
				bootbox.alert('请填写正确的日期时间！');
			}else{
				var _this = a(this);
				a.ajax({
					type: 'POST',
					url: FBTOOLS.createUrl('manage/editGameSchedule'),
					data: {'gameid':gameid,'game_date':game_date, 'game_time':game_time,'game_address':game_address},
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