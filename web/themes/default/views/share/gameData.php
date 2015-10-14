<?php $this->pageTitle="比赛数据 － ".Yii::app()->name; ?>

<?php

	if( $teamId==$gameData->home_court->objectId ){ //是主队
		if(property_exists($gameData, "score_h") ){
			$score_h = $gameData->score_h;
		}else{
			$score_h = 0;
		}

		if(property_exists($gameData, "score_h2") ){
			$score_o = $gameData->score_h2;
		}else{
			$score_o = 0;
		}
	}else{ //是客队
		if(property_exists($gameData, "score_o2") ){
			$score_h = $gameData->score_o2;
		}else{
			$score_h = 0;
		}

		if(property_exists($gameData, "score_o") ){
			$score_o = $gameData->score_o;
		}else{
			$score_o = 0;
		}		
	}

	if(isset($gameData->site) && !empty($gameData->site)){
		$site = $gameData->site;
	}else{
		$site = '未知场地';
	}

	if(isset($gameData->league->name) && !empty($gameData->league->name)){
		$leagueName = $gameData->league->name;
	}else{
		$leagueName = '未知联赛';
	}

	if(isset($gameData->nature) && !empty($gameData->nature)){
		$nature = $gameData->nature;
	}else{
		$nature = 1;
	}

	if(isset($gameData->start_time->iso) && !empty($gameData->start_time->iso)){
		$startTime = $gameData->start_time->iso;
		$dateTimeArr = explode(' ',$startTime);
		$dateArr = explode('-',$dateTimeArr[0]);
		if(isset($dateTimeArr[0])){
			$gameDateDetail = $dateTimeArr[0];
		}else{
			$gameDateDetail = '未知时间';
		}
	}else{
		$gameDateDetail = '未知时间';
	}

	if(isset($gameData->league->name) && !empty($gameData->league->name)){
		$leagueName = $gameData->league->name;
	}else{
		$leagueName = '未知联赛';
	}

	if(isset($gameData->name) && !empty($gameData->name)){
		$teamArr = explode('-',$gameData->name);
		if(isset($teamArr[0])){
			$homeTeam = $teamArr[0];
		}else{
			$homeTeam = '未知球队';
		}
		if(isset($teamArr[1])){
			$guestTeam = $teamArr[1];
		}else{
			$guestTeam = '未知球队';
		}
	}else{
		$homeTeam = '未知球队';
		$guestTeam = '未知球队';
	}

				//是否显示射手榜
				$showPlayerAssists=false;
				 foreach($playerRangeArr as $playerRange){
						if($playerRange['totalGoals']>0){
							$showPlayerAssists=true;
							break;
						}
				}

				//是否显示助攻榜
				$showPlayerAssistsRange=false;					
			 	foreach($playerAssistsRangeArr as $playerRange) {
						if($playerRange['totalAssists']>0){
							$showPlayerAssistsRange=true;
							break;
						}
				}

?>
<div class="container-fluid content-blue-bg whole-w-h">
	<div class="row">
		<div class="col-xs-12 ">
			<div class="game-score-l">
				<?php echo $homeTeam; ?><span class="game-score-l-score"><?php echo $score_h; ?>-<?php echo $score_o; ?></span><?php echo $guestTeam; ?>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-xs-12 ">
			<div class="game-detail-l">
				<ul>
					<li><p class="game-detail-l-n"><?php echo $gameDateDetail; ?>   <?php echo $site; ?></p></li>
					<li><p class="game-detail-l-w"><?php echo $leagueName; ?>-<?php echo CommonFunction::code2GameFormat($nature); ?></p></li>
				</ul>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-xs-12 ">
			<div class="game-detail-l">
				<!-- Nav tabs -->
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="#shooter_range" role="tab" data-toggle="tab">射手榜</a></li>
					<li role="presentation"><a href="#assits_range" role="tab" data-toggle="tab">助攻榜</a></li>
					<li role="presentation"><a href="#assits_member" role="tab" data-toggle="tab">阵容</a></li>
				</ul>

				<!-- Tab panes -->
				<div class="tab-content">
					<div role="tabpanel" class="tab-pane active" id="shooter_range">
						<div class="range-table-n range-table-n-playerbg">
							<div class="title-underline">
								<strong>射手榜</strong>
							</div>
							<table>
								<?php if( 	$showPlayerAssists ):?>
									<tr><th>排名</th><th>球员</th><th>球队名称</th><th>进球数</th></tr>
									<?php $count = 1; foreach($playerRangeArr as $playerRange): ?>
										<?php
										if($count > 5){break;}
										?>
										<tr><td><?php echo $count; ?></td><td><?php echo $playerRange['name']; ?></td><td><?php echo $playerRange['team']; ?></td><td><?php echo $playerRange['totalGoals']; ?></td></tr>
									<?php $count++; endforeach; ?>
								<?php endif; ?>

							</table>
						</div>
<!--						<img src="--><?php //echo Yii::app()->params['themeAssetHost'] ?><!--images/person-football-img.png"/>-->
					</div>
					<div role="tabpanel" class="tab-pane" id="assits_range">
						<div class="range-table-n range-table-n-playgroundbg">
							<div class="title-underline">
								<strong>助攻榜</strong>
							</div>
							<table>
								<?php if( 	$showPlayerAssistsRange ):?>
									<tr><th>排名</th><th>球员</th><th>球队名称</th><th>助攻数</th></tr>
									<?php $count = 1; foreach($playerAssistsRangeArr as $playerRange): ?>
										<?php
										if($count > 5){break;}
										?>
										<tr><td><?php echo $count; ?></td><td><?php echo $playerRange['name']; ?></td><td><?php echo $playerRange['team']; ?></td><td><?php echo $playerRange['totalAssists']; ?></td></tr>
										<?php $count++; endforeach; ?>
								<?php endif;?>
							</table>
						</div>
<!--						<img src="--><?php //echo Yii::app()->params['themeAssetHost'] ?><!--images/playground-line-img.png" />-->
					</div>
					
					<div role="tabpanel" class="tab-pane" id="assits_member">
						<div class="range-table-n range-table-n-playgroundbg">
							<div class="title-underline">
								<strong>阵容</strong>
							</div>
							<table>
								<tr><th>球员</th><th>球队名称</th></tr>
									<?php if( count($playMembers) ): ?>
										<?php   foreach($playMembers as $key=>$member): ?>
											
										
												<tr><td><?php echo $member->player->nickname ?></td><td><?php echo $member->team->name; ?></td><td></td><td></td></tr>
											
										<?php  endforeach; ?>
									<?php endif; ?>
							</table>
						</div>
<!--						<img src="--><?php //echo Yii::app()->params['themeAssetHost'] ?><!--images/playground-line-img.png" />-->
					</div>					
					
				</div>
			</div>
		</div>
	</div>

<!--	<div class="row fixed-zw"></div>-->
<!--	<div class="row logo-banner navbar-fixed-bottom">-->
<!--		<div class="col-xs-12">-->
<!--			<div class="row">-->
<!--				<div class="col-xs-12"><strong>数据来自：</strong></div>-->
<!--			</div>-->
<!--			<div class="row">-->
<!--				<div class="col-xs-7"><img src="--><?php //echo Yii::app()->params['themeAssetHost'] ?><!--images/share-logo.png" class="autosize-img"></div>-->
<!--				<div class="col-xs-5 text-right pt10"><img src="--><?php //echo Yii::app()->params['themeAssetHost'] ?><!--images/share-download-btn.png" class="autosize-img"></div>-->
<!--			</div>-->
<!--		</div>-->
<!--	</div>-->

</div>
<div class="row logo-banner">
	<div class="col-sm-12">
		<div class="row">
			<div class="col-sm-12"><strong>数据来自</strong></div>
		</div>
		<div class="row">
			<div class="col-xs-7"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-logo.png" width="337" height="99"  class="autosize-img"></div>
			<div class="col-xs-5 text-right pt10"><a href="/share/download"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-download-btn.png" width="193" height="71" class="autosize-img"></a></div>
		</div>
	</div>
</div>
<script type="text/javascript">
	(function(){
		var screenH = window.screen.availHeight
		var screenW = window.screen.availWidth
		$(".whole-w-h").height(screenH);
		$(".whole-w-h").width(screenW);
	})()
</script>

