<style>
	body{background: #ffffff;}

</style>

<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content">
				<?php if(!empty($games)): ?>
					<div class="schedule-wrap">
						<div class="block-title clearfix">
							<strong class="pull-left">编辑赛程</strong>
							<div class="pull-right menu"><a class="btn btn-primary">查看赛程</a></div>
						</div>
						<div class="schedule-block">
							<?php foreach($games as $game): ?>
								<?php
								if(!isset($game->event_date)){
									$game->event_date = '日期未定';
								}
								if(!isset($game->start_time)){
									$game->start_time = '时间未定';
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
								<div class="row team-vs-wrap">
									<div class="col-md-2">
										<ul>
											<li><div class="text-tiny-gray"><?php echo $game->event_date; ?></div></li>
											<li><div class="text-f2x"><?php echo $game->start_time; ?></div></li>
										</ul>
									</div>
									<div class="col-md-1"></div>
									<div class="col-md-6">
										<table class="team-vs">
											<tr><td><div class="text-f2x team-vs-name"><span class="home-team"><?php echo $homeCourtName ?></span><i class="vs-icon"></i><span class="guest-team"><?php echo $opponentName ?></span></div></td></tr>
											<tr><td class="game-detail"><i class="fa fa-map-marker"></i><span class="game-location"><?php echo $game->site; ?></span><p class="bg-primary"><?php echo CommonFunction::code2GameFormat($game->nature); ?></p></td></tr>
										</table>
									</div>
									<div class="col-md-1">

									</div>
									<div class="col-md-2">
										<a class="btn btn-primary btn-xs edit-game-schedule">编辑赛事</a>
									</div>
								</div>
							<?php endforeach; ?>
						</div>
					</div>
				<?php endif; ?>
			</div>
		</div>
		<div class="col-md-3">
			<?php echo $this->renderPartial('//manage/_sidebar',array('leagueTeams'=>$leagueTeams)); ?>
		</div>
	</div>
</div>

<div id="edit_game_schedule" style="display: none">
	<form class="form-horizontal" id="form-select-team" role="form">
		<div class="edit-schedule-block">
			<ul class="row">
				<li class="clearfix">
					<div class="close-btn"><i class="close-circle-btn"></i></div>
					<table class="form-horizontal col-md-12 col-sm-12">
						<tbody><tr><td>
								<div class="form-group">
									<label class="col-sm-3 control-label">时间：</label>
									<div class="col-sm-9">
										<div class="input-group">
											<input type="text" class="form-control datepicker">
											<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
										</div>
									</div>
								</div>
							</td>
							<td>
								<div class="form-group">
									<label class="col-sm-3 control-label">地点：</label>
									<div class="col-sm-9">
										<input type="text" class="form-control">
									</div>
								</div>
							</td>
						</tr>
						<tr><td>
								<div class="form-group">
									<label class="col-sm-3 control-label">时刻：</label>
									<div class="col-sm-9">
										<div class="input-group">
											<input type="text" class="form-control timepicker">
											<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
										</div>
									</div>
								</div>
							</td>
							<td rowspan="2">
								<div class="">
									<div class="team-vs-block">小白菜队</div>
									<i class="vs-icon"></i>
									<div class="team-vs-block">老白菜队</div>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<div class="form-group">
									<label class="col-sm-3 control-label">性质：</label>
									<div class="col-sm-9">
										<input type="text" class="form-control">
									</div>
								</div>
							</td>
						</tr>
						</tbody></table>
				</li>

			</ul>
		</div>
	</form>
</div>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datepicker/bootstrap-datepicker.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datetimepicker/moment.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datetimepicker/bootstrap-datetimepicker.min.js"></script>


<script type="text/javascript">

	(function(a){

		a("body").delegate('.datepicker','datetimepicker',function(){
			a('.datepicker').datetimepicker({
				pickTime: false
			});
		});

		a('.timepicker').datetimepicker({
			pickDate: false
		});

		FBTOOLS.editDialog(".edit-game-schedule","#edit_game_schedule","编辑赛程",function(_this){

		});

	})(jQuery);

</script>

