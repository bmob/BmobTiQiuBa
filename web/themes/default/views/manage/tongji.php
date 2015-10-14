<?php $this->pageTitle="数据统计 － ".Yii::app()->name; ?>

<style>
	body{background: #ffffff;}
</style>

<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content">
				<div class="scoreboard-wrap">
					<div class="block-title clearfix">
						<strong class="pull-left">
							积分榜
							<small>( 每天更新 )</small>
						</strong>
						<button class="btn btn-primary pull-right" id="up_league_data" data-leagueid = "<?php echo $leagueId ?>">立即更新</button>
					</div>
					<?php foreach($groupRows as $group): ?>
						<div>
							<ul>
								<li class="clearfix table-title"><span class="text-align-block table-title-name"><?php echo $group->name; ?>组</span><div class="pull-right menu"></div></li>
								<li>
									<table class="table table-bordered">
										<tr><th>排名</th><th>球队</th><th>胜</th><th>平</th><th>负</th><th>进球</th><th>失球</th><th>净胜球</th><th>积分</th></tr>
										<?php if(isset($group->relteams) && is_array($group->relteams)): ?>
											<?php $count = 1; foreach($group->relteams as $team): ?>
												<?php
													$name = isset($team->name) ? $team->name : '未知球队';
													$win = isset($team->stat->win) ? $team->stat->win : '未统计';
													$draw = isset($team->stat->draw) ? $team->stat->draw : '未统计';
													$loss = isset($team->stat->loss) ? $team->stat->loss : '未统计';
													$goals = isset($team->stat->goals) ? $team->stat->goals : '未统计';
													$goals_against = isset($team->stat->goalsAgainst) ? $team->stat->goalsAgainst : '未统计';
													$goal_difference = isset($team->stat->goalDifference) ? $team->stat->goalDifference : '未统计';
													$points = isset($team->stat->points) ? $team->stat->points : '未统计';
												?>
												<tr>
													<td><?php echo $count; ?></td>
													<td><?php echo $name; ?></td>
													<td><?php echo $win; ?></td>
													<td><?php echo $draw; ?></td>
													<td><?php echo $loss; ?></td>
													<td><?php echo $goals; ?></td>
													<td><?php echo $goals_against; ?></td>
													<td><?php echo $goal_difference; ?></td>
													<td><?php echo $points; ?></td>
												</tr>
											<?php $count++; endforeach; ?>
										<?php endif; ?>
									</table>
								</li>
							</ul>
						</div>
					<?php endforeach; ?>
				</div>

				<div class="shooterboard-wrap">
					<div class="block-title clearfix">
						<strong class="pull-left">
							射手榜
							<small>( 每天更新 )</small>
						</strong>
						<button class="btn btn-primary pull-right" id="up_shooter_data" data-leagueid = "<?php echo $leagueId ?>">立即更新</button>
					</div>
					<div class="shooterboard-block">
						<table class="table table-bordered">
							<tr><th>排名</th><th>球员</th><th>球队</th><th>进球</th></tr>
							<?php $count = 1; foreach($playerRangeArr as $playerRange): ?>
								<?php
									if($count > 10){break;}
								?>
								<tr><td><?php echo $count; ?></td><td><?php echo $playerRange['name']; ?></td><td><?php echo $playerRange['team']; ?></td><td><?php echo $playerRange['totalGoals']; ?></td></tr>
							<?php $count++; endforeach; ?>
						</table>
					</div>
				</div>

			</div>
		</div>
		<div class="col-md-3">
			<?php echo $this->renderPartial('//manage/_sidebar_g',array('groupTeams'=>$groupTeams)); ?>
		</div>
	</div>
</div>
<script type="text/javascript">

	$(function(){

		$("#up_league_data").click(function(){

			var league_id = $(this).data('leagueid');

			$.ajax({
				type: 'POST',
				url: FBTOOLS.createUrl('League/updateLeagueRange'),
				data: {'leagueid':league_id},
				dataType: 'json',
				async: false,
				beforeSend: function (){

				},
				success: function (result){
					if(!FBTOOLS.checkAjaxResult(result)){
						return false;
					}

					if(result.status.code == 1000){
						bootbox.alert('联赛榜单已更新！');
						window.location.reload();
					}else{
						bootbox.alert('操作有误！');
					}
				},
				error: function(result){
					alert('操作有误！');
				}
			});

		})

		$("#up_shooter_data").click(function(){

			var league_id = $(this).data('leagueid');

			$.ajax({
				type: 'POST',
				url: FBTOOLS.createUrl('League/UpdateShooterData'),
				data: {'leagueid':league_id},
				dataType: 'json',
				async: false,
				beforeSend: function (){

				},
				success: function (result){

					if(!FBTOOLS.checkAjaxResult(result)){
						return false;
					}

					if(result.status.code == 1000){
						bootbox.alert('联赛射手榜已更新！');
						window.location.reload();
					}else{
						bootbox.alert('操作有误！');
					}

				},

				error: function(result){
					alert('操作有误！');
				}

			});

		});

	})

</script>