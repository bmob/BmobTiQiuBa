<?php $this->pageTitle="球员评论 － ".Yii::app()->name; ?>

<style>

</style>
<div class="container-fluid">
	<div class="row">
		<div class="col-xs-12">
			<p class="descript-bold">
				<?php

					if(isset($playerScore->player->nickname) && !empty($playerScore->player->nickname)){
						$nickname = $playerScore->player->nickname;
					}else{
						$nickname = '该球员';
					}

					if(isset($playerScore->competition->start_time->iso) && !empty($playerScore->competition->start_time->iso)){
						$startTime = $playerScore->competition->start_time->iso;
						$dateTimeArr = explode(' ',$startTime);
						$dateArr = explode('-',$dateTimeArr[0]);
						if(isset($dateArr[1]) && isset($dateArr[2])){
							$gameDate = $dateArr[1].'月'.$dateArr[2].'日';
						}else{
							$gameDate = '某个时间';
						}
					}else{
						$gameDate = '某个时间';
					}

					if(isset($playerScore->competition->name) && !empty($playerScore->competition->name)){
						$teamArr = explode('-',$playerScore->competition->name);
						if(isset($teamArr[0])){
							$homeTeam = $teamArr[0];
						}else{
							$homeTeam = $teamArr[0];
						}
						if(isset($teamArr[1])){
							$guestTeam = $teamArr[1];
						}else{
							$guestTeam = $teamArr[1];
						}
					}else{
						$homeTeam = '未知球队';
						$guestTeam = '未知球队';
					}

					if(isset($playerScore->goals) && !empty($playerScore->goals)){
						$goals = $playerScore->goals;
					}else{
						$goals = 0;
					}

					if(isset($playerScore->assists) && !empty($playerScore->assists)){
						$assists = $playerScore->assists;
					}else{
						$assists = 0;
					}

					if(isset($playerScore->avg) && !empty($playerScore->avg)){
						$avg = round($playerScore->avg,1);
					}else{
						$avg = 0;
					}

				?>
				<?php echo $nickname; ?>在
				<?php echo $gameDate; ?>
				<?php echo $homeTeam; ?>
				同
				<?php echo $guestTeam; ?>
				的比赛中
				打进<?php echo $goals; ?>球，
				助攻<?php echo $assists; ?>次，
				大家对他的评分是：
			</p>
		</div>
	</div>
	<div class="row">
		<div class="col-xs-12">
			<p class="text-c-y"><span class="size-lg-3x"><?php echo $avg; ?></span>分</p>
		</div>
	</div>
	<div class="row comment-list">
		<div class="col-xs-12">

			<table>
				<tr><td colspan="2"><p class="descript-bold"><?php echo $nickname ?>本场比赛获得的评分为：</p></td></tr>
				<?php foreach($comments as $comment):?>
				<tr>
					<td class="comment-list-left">
						<span class="dashed-box-gray-n">
							<?php
								if(isset($comment->komm->nickname) && !empty($comment->komm->nickname)){
									echo $comment->komm->nickname;
								}else{
									echo '匿名';
								}
							?>
							<strong class="pl5">
								<?php
									if(isset($comment->score) && !empty($comment->score)){
										echo $comment->score;
									}else{
										echo '';
									}
								?>
							</strong>
						</span>
					</td>
					<td>
						<p class="dialog-box-n">
							<?php
								if(isset($comment->comment) && !empty($comment->comment)){
									echo $comment->comment;
								}else{
									echo '';
								}
							?>
						</p>
					</td>
				</tr>
				<?php endforeach; ?>

			</table>
		</div>
	</div>
	<div class="row fixed-zw"></div>
	<div class="row logo-banner navbar-fixed-bottom">
		<div class="col-sm-12">
			<div class="row">
				<div class="col-sm-12"><strong>数据来自</strong></div>
			</div>
			<div class="row">
				<div class="col-xs-7"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-logo.png" width="337" height="99"  class="autosize-img"></div>
				<div class="col-xs-5 text-right pt10"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-download-btn.png" width="193" height="71" class="autosize-img"></div>
			</div>
		</div>
	</div>
</div>

