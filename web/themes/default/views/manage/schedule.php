<?php $this->pageTitle="编辑赛程 － ".Yii::app()->name; ?>

<style>
	body{background: #ffffff;}
	.team-vs-wrap{background: url("<?php echo Yii::app()->params['themeAssetHost'] ?>images/line-circle-small.png") 165px -43px no-repeat;}
</style>

<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content">
				<?php if(isset($groupTeams) && !empty($groupTeams)): ?>
					<div>
						<table class="table">
							<tr><th>小组名称</th><th>小组成员</th></tr>
							<?php $count = 1;  foreach($groupTeams as $group):?>
								<tr>
									<td>
										<?php echo $count.'组'; ?>
									</td>
									<td>
										<?php foreach($group as $team): ?>
											<div class="btn-group" data-teamid="<?php echo $team->objectId ?>">
												<button type="button" class="btn btn-success"><?php echo $team->name ?></button>
											</div>
										<?php endforeach; ?>
									</td>
								</tr>
							<?php $count++; endforeach; ?>
						</table>
					</div>
				<?php else: ?>
					<div class="alert alert-danger">你还未设置联赛分组</div>
					<div>
						<a class="btn btn-primary" href="/manage/grouping">设置联赛分组</a>
					</div>
				<?php endif; ?>

				<?php if(!empty($games)): ?>
					<div class="schedule-wrap">
						<div class="block-title clearfix">
							<strong class="pull-left">赛程</strong>
						
							<div class="pull-right menu">
							<?php if( $isKnockout ): ?>
										<a class="btn btn-primary" href="/manage/addManage">添加淘汰赛赛程</a>
							<?php endif; ?>	
							<a class="btn btn-primary" href="/manage/editManage">编辑赛程</a>
							
							</div>
						</div>
						<div class="schedule-block">
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
								<div class="row team-vs-wrap">
									<div class="col-md-2">
										<ul>
											<li><div class="text-tiny-gray"><?php echo $eventDate; ?></div></li>
											<li><div class="text-f2x"><?php echo $startTime; ?></div></li>
										</ul>
									</div>
									<div class="col-md-1"></div>
									<div class="col-md-9">
										<table class="team-vs">
											<tr><td><div class="text-f2x team-vs-name"><span class="home-team"><?php echo $homeCourtName; ?></span><i class="vs-icon"></i><span class="guest-team"><?php echo $opponentName; ?></span></div></td></tr>
											<tr><td class="game-detail"><i class="fa fa-map-marker"></i><span class="game-location"><?php echo $game->site; ?></span><p class="bg-primary"><?php echo CommonFunction::code2GameFormat($game->nature.""); ?></p></td></tr>
										</table>
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

