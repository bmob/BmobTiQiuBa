<?php $this->pageTitle="个人数据 － ".Yii::app()->name; ?>

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
			if(isset($dateTimeArr[0])){
				$gameDateDetail = $dateTimeArr[0];
			}else{
				$gameDateDetail = '未知时间';
			}
			if(isset($dateArr[1]) && isset($dateArr[2])){
				$gameDate = $dateArr[1].'月'.$dateArr[2].'日';
			}else{
				$gameDate = '某个时间';
			}
		}else{
			$gameDateDetail = '未知时间';
			$gameDate = '某个时间';
		}

		if(isset($playerScore->competition->name) && !empty($playerScore->competition->name)){
			$teamArr = explode('-',$playerScore->competition->name);
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

		if(isset($playerScore->competition->site) && !empty($playerScore->competition->site)){
			$gamesite = $playerScore->competition->site;
		}else{
			$gamesite = '未知场地';
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

<div class="container-fluid">
	<div class="row data-name-num">
		<div class="col-xs-12 pl0">
			<ul>
				<li><strong><?php echo $nickname; ?></strong></span></li>
			</ul>
		</div>
	</div>
	<div class="row" style="position: relative;">
		<div class="col-xs-12 p0">
			<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-person-data-bg.png" class="autosize-img" width="720" height="713"/>
		</div>
		<div class="p-data-disc autosize-img-wrap">
			<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-data-yw.png" class="autosize-img" width="424" height="96" />
			<div class="p-data-disc-t">
				<ul>
					<li><p class="t-cw autosize-wc-h"><?php echo $nickname; ?></p></li>
					<li><p class="autosize-wc-h">本场进球 <?php echo $goals; ?>&nbsp;&nbsp;&nbsp;&nbsp;本场助攻 <?php echo $assists; ?></p></li>
				</ul>
			</div>
		</div>

	</div>

	<div class="row">
		<div class="col-xs-12 p0">
			<table class="col-xs-12 p0 game-table-line">
				<tr>
					<td valign="top">
						<div class="box-title-l">
							<div class="box-title">比赛</div>
							<div class="box-team-vs row">
								<ul>
									<li><div class="col-xs-12"><?php echo $homeTeam; ?></div></li>
									<li><div class="col-xs-12 text-center"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-vs-icon-sm.png" class="autosize-img" width="25" height="25"/></div></li>
									<li><div class="col-xs-12"><?php echo $guestTeam; ?></div></li>
								</ul>
							</div>
						</div>
					</td>
					<td valign="top">
						<div class="box-title-l">
							<div class="box-title">时间</div>
							<div class="box-content">
								<p class="box-line-p"><?php echo $gameDateDetail; ?></p>
							</div>
						</div>
					</td>
					<td valign="top">
						<div class="box-title-l">
							<div class="box-title">地点</div>
							<div class="box-content">
								<p class="box-line-p"><?php echo $gamesite; ?></p>
							</div>
						</div>
					</td>
				</tr>
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
				<div class="col-xs-5 text-right pt10"><a href="/share/download"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-download-btn.png" width="193" height="71" class="autosize-img"></a></div>
			</div>
		</div>
	</div>
</div>

