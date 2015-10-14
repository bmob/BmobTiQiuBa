<?php $this->pageTitle="比赛结果 － ".Yii::app()->name; ?>
<style>
	body{background: #ffffff;}
	.team-vs-wrap{background: url("<?php echo Yii::app()->params['themeAssetHost'] ?>images/line-circle-small-one.png") 165px -80px no-repeat;}
</style>

<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content">
				<div class="game-resultboard-wrap">
					<div class="block-title clearfix">
						<strong class="pull-left">比赛结果<small>( 将右栏中比赛结果拖拽至“+”区块即可 )</small></strong>
					</div>
<!--					--><?php //var_dump($games) ?>
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

						if(!isset($game->score_h) || !isset($game->isVerify)){
							$game->score_h = '--';
						}
						if(isset($game->allowResultEdit) && $game->allowResultEdit){
							$game->score_h = '<input type="text" class="form-control home-team-score-val"  style="width: 30px;padding: 3px 2px;text-align: center;">';
						}

						if(!isset($game->score_o) || !isset($game->isVerify)){
							$game->score_o = '--';
						}

						if(isset($game->allowResultEdit) && $game->allowResultEdit){
							$game->score_o = '<input type="text" class="form-control opponent-team-score-val"  style="width: 30px;padding: 3px 2px;text-align: center;">';
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
							<div class="col-md-7">
								<table class="team-vs">
									<tr>
										<td class="game-detail" style="text-align: left">
											<i class="fa fa-map-marker"></i>
											<span class="game-location"><?php echo $game->site; ?></span>
											<p class="bg-primary"><?php echo CommonFunction::code2GameFormat($game->nature); ?></p>
											<div class="pull-right" id="<?php echo "game_verify_".$game->objectId; ?>">
												<?php if(isset($game->allowResultEdit) && $game->allowResultEdit): ?>
													<i class="fa fa-minus-circle color-warning"></i>&nbsp;&nbsp;<span class="verify-status">未认证</span>
												<?php elseif(isset($game->allowResultEdit) && !$game->allowResultEdit && !isset($game->isVerify)): ?>
													<i class="fa fa-minus-circle color-warning"></i>&nbsp;&nbsp;<span class="verify-status">未认证</span>
												<?php else: ?>
													<i class="fa fa-minus-circle color-success"></i>&nbsp;&nbsp;<span class="verify-status">已认证</span>
												<?php endif; ?>
											</div>
											<?php if(isset($game->allowResultEdit) && !$game->allowResultEdit && !isset($game->isVerify)): ?>
												<div class="help-block">比赛结束未超6小时，且双方所填比分不一致，等待重新比对比分</div>
											<?php endif; ?>
											<?php if(isset($game->allowResultEdit) && $game->allowResultEdit): ?>
												<div class="help-block">比赛结束已超6小时，且未通过认证的，则管理员可编辑赛果</div>
											<?php endif; ?>

										</td>
									</tr>
									<tr><td>
											<div class="text-f2x team-vs-name clearfix" id="<?php echo "game_result_".$game->objectId; ?>">
												<table>
													<tr>
														<td valign="top">
															<span class="home-team"><?php echo $homeCourtName;?></span><br/><br/>
															<?php

																if(isset($game->home_court->playerscore)){
																	//var_dump($game->home_court->playerscore);exit;
																	foreach($game->home_court->playerscore as $playerscore){
																		echo '<div class="score-player"><i class="fa fa-dribbble color-green2"></i>'.$playerscore['player'].' × '.$playerscore['score'].'</div>';
																	}
																}

															?>

														</td>
														<td valign="top">
															<span class="game-score" id="<?php echo "home_team_score_".$game->objectId; ?>"><?php echo $game->score_h ?></span><span class="game-score-sp">：</span><span class="game-score" id="<?php echo "opponent_team_score_".$game->objectId; ?>"><?php echo $game->score_o ?></span>
														</td>
														<td valign="top">
															<span class="guest-team"><?php echo $opponentName;?></span><br/><br/>
															<?php
															if(isset($game->opponent->playerscore)){
																foreach($game->opponent->playerscore as $playerscore){
																	echo '<div class="score-player"><i class="fa fa-dribbble color-green2"></i>'.$playerscore['player'].' × '.$playerscore['score'].'</div>';
																}
															}
															?>
														</td>
													</tr>
<!--													<tr><td><div class="score-player"><i class="fa fa-dribbble color-green2"></i>柿谷曜一朗</div></td><td></td><td><div class="score-player"><i class="fa fa-dribbble color-green2"></i>柿谷曜一朗</div></td></tr>-->
<!--													<tr><td><div class="score-player"><i class="fa fa-dribbble color-green2"></i>柿谷曜一朗</div></td><td></td><td><div class="score-player"><i class="fa fa-dribbble color-green2"></i>柿谷曜一朗</div></td></tr>-->
<!--													<tr><td><div class="score-player"><i class="fa fa-dribbble color-green2"></i>柿谷曜一朗</div></td><td></td><td><div class="score-player"><i class="fa fa-dribbble color-green2"></i>柿谷曜一朗</div></td></tr>-->
												</table>
											</div>
										</td>
									</tr>
								</table>
							</div>
							<div class="col-md-2">
								<?php if(isset($game->allowResultEdit) && $game->allowResultEdit): ?>
<!--									<a class="btn btn-primary btn-xs pull-right edit-game-result-btn" data-gameid="--><?php //echo $game->objectId; ?><!--">编辑赛果</a>-->
									<a class="btn btn-primary btn-xs pull-right save-game-result-btn" data-gameid="<?php echo $game->objectId; ?>">保存赛果</a>
								<?php endif; ?>
							</div>
						</div>
					<?php endforeach; ?>

				</div>
			</div>
		</div>
		<div class="col-md-3">
			<?php echo $this->renderPartial('//manage/_sidebar_g',array('groupTeams'=>$groupTeams)); ?>
		</div>
	</div>
</div>

<div id="fill_score_form" style="display: none">

		<form class="form-horizontal" id="form-select-team" role="form">

<!--			<div class="form-group">-->
<!--				<label for="home_team" class="col-sm-3 control-label">主队比分：</label>-->
<!--				<div class="col-sm-9">-->
<!--					<input type="text" class="form-control home-team"  >-->
<!--				</div>-->
<!--			</div>-->
<!--			<div class="form-group">-->
<!--				<label for="opponent_team" class="col-sm-3 control-label">客队比分：</label>-->
<!--				<div class="col-sm-9">-->
<!--					<input type="text" class="form-control opponent-team" >-->
<!--				</div>-->
<!--			</div>-->

		</form>

</div>

<script type="text/javascript">
	(function(a){

		a(".team-vs-wrap").delegate('.save-game-result-btn','click',function(){
			var _this = a(this);
			bootbox.confirm("确定要修改本场比赛的比分吗？", function(result) {

				var gameid = _this.data("gameid");
				var _id = a("#game_result_"+gameid);
				var home_team_score = Number(_id.find(".home-team-score-val").val());
				var opponent_team_score = Number(_id.find(".opponent-team-score-val").val());

				var homeTeamScore = FBTOOLS.regTest(/^\d+$/,home_team_score);
				var opponentTeamScore = FBTOOLS.regTest(/^\d+$/,opponent_team_score);

				if(!(homeTeamScore && opponentTeamScore)){
					bootbox.alert('比分只能为数字！');
				}else{

					a.ajax({
						type: 'POST',
						url: FBTOOLS.createUrl('manage/editGameResult'),
						data: {'gameid':gameid,'home_team_score':home_team_score, 'opponent_team_score':opponent_team_score},
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
								a("#home_team_score_"+gameid).html(home_team_score);
								a("#opponent_team_score_"+gameid).html(opponent_team_score);
								a("#game_verify_"+gameid).find("i").removeClass("color-warning").addClass("color-success");
								a("#game_verify_"+gameid).find(".verify-status").html("已认证");
								a("#game_verify_"+gameid).next(".help-block").remove();
								_this.remove();
							}else{
								bootbox.alert('保存失败！');
							}
						}
					});
				}
			});

		});


	})(jQuery)

</script>

