<?php $this->pageTitle="联赛数据 － ".Yii::app()->name; ?>

<div class="container-fluid">
	<?php echo $this->renderPartial('//share/_banner'); ?>
	<div class="row fixed-zw"></div>
	<div class="row champion-cup">
		<div class="col-xs-12 text-center">
			<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-champion-cup.png" width="90" height="90" class="autosize-img">
			<p class="champion-cup-name"><?php echo $leagueName ?></p>
		</div>

	</div>
	<div class="row league-data">
		<div class="col-xs-12 p0">
			<div>
				<?php foreach($groupRows as $group): ?>
					<div>
						<div class="col-xs-12 league-data-title">
							<?php
								if(isset($group->name) && !empty($group->name)){
									echo $group->name.'组';
								}else{
									echo '未知组名';
								}
							?>

						</div>
							<table class="table table-bordered">
								<tr><th>排名</th><th>球队</th><th>胜</th><th>平</th><th>负</th><th>进</th><th>失</th><th>净胜</th><th>分</th></tr>
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
						</div>
					</div>
				<?php endforeach; ?>
<!--				<div class="col-xs-12 league-data-title">1组</div>-->
<!--				<table class="col-xs-12 table-bordered table-striped p0">-->
<!--					<tr><th>排名</th><th>球队名称</th><th>胜</th><th>平</th><th>负</th><th>进球</th><th>失球</th><th>净胜球</th><th>积分</th></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--				</table>-->
<!--				<div class="col-xs-12 league-data-title">2组</div>-->
<!--				<table class="col-xs-12 table-bordered table-striped p0">-->
<!--					<tr><th>排名</th><th>球队名称</th><th>胜</th><th>平</th><th>负</th><th>进球</th><th>失球</th><th>净胜球</th><th>积分</th></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--					<tr><td>1</td><td>浦项制铁</td><td>3</td><td>2</td><td>1</td><td>9</td><td>7</td><td>3</td><td>22</td></tr>-->
<!--				</table>-->
			</div>
		</div>
	</div>
</div>
