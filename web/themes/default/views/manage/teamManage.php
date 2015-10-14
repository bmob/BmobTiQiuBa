<?php $this->pageTitle="球队管理 － ".Yii::app()->name; ?>

<style>
	body{background: #ffffff;}
	.invite-team-wrap .form-group{margin-bottom: 5px;}
</style>

<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content"  data-leagueid="<?php echo $leagueList->objectId; ?>">

				<div class="invite-team-wrap">
					<div class="block-title cancle-line-bottom clearfix">
						<strong class="pull-left">邀请球队</strong>
					</div>
					<div class="help-block">可向被邀请球队队长发送短信，对方按照短信中联赛邀请码注册即可。(同一个号码，每天最多只能发三条短信！)</div>
					<div>
						<div class="form-group btn-in-input col-md-5" >
							<div class="form-group">
								<input type="text" class="form-control"  placeholder="队名" id="invite_team_name">
							</div>
						</div>
						<div class="form-group btn-in-input col-md-6">
							<div class="form-group">
								<input type="text" class="form-control"  placeholder="队长手机号" id="invite_captain_name">
							</div>
						</div>
						<div class="form-group btn-in-input col-md-1">
							<div class="form-group">
								<button class="btn btn-primary" id="invite_team">邀请</button>
							</div>
						</div>
					</div>
					<div class="help-block" style="color: #ff0000;display: none;" id="invite_team_notice">你所邀请的用户已创建了球队：<strong id="invite_in_team"></strong>，请在下方搜索添加</div>
				</div>

				<div class="search-team-wrap">
					<div class="block-title cancle-line-bottom clearfix">
						<strong class="pull-left">添加球队</strong>
					</div>
					<div>
						<div class="form-group btn-in-input">
							<span><a class="input-btn btn btn-primary" id="search_teams">搜索</a></span>
							<div class="form-group">
								<input type="text" class="form-control" id="search_teams_input" placeholder="搜索球队">
							</div>
						</div>
					</div>
				</div>

				<div class="search-result-wrap">
					<div class="search-result-block">
						<div><strong>搜索结果：</strong></div>
						<ul id="search_team_result">
							<?php foreach($initTeams as $team):  ?>
								<?php
									if(!isset($team->name) || empty($team->name)){
										$team->name = '未知球队';
									}
									if(!isset($team->hasLeague) || empty($team->hasLeague)){
										$team->hasLeague = false;
									}
									if(!isset($team->cityname)){
										$team->cityname = '未知城市';
									}
									if(!isset($team->captain->nickname) || empty($team->captain->nickname)){
										$captainName = '匿名';
									}else{
										$captainName = $team->captain->nickname;
									}
								?>
								<li class="search-result-row">
									<table >
										<tr>
											<td style="text-align: left"><?php echo $team->name ?></td>
											<td rowspan="2" style="text-align: right">
												<button class="btn btn-info btn-xs add-to-league <?php if($team->hasLeague){echo 'disabled';} ?>" data-teamid="<?php echo $team->objectId; ?>"><?php if($team->hasLeague){echo '已添加';}else{echo '添加至联赛';} ?></button>
											</td>
										</tr>
										<tr>
											<td style="text-align: left">
												<?php echo $team->cityname ?> / 队长：<?php echo $captainName ?>
											</td>
										</tr>
									</table>
								</li>
							<?php endforeach; ?>
						</ul>
					</div>
				</div>

			</div>
		</div>
		<div class="col-md-3">
			<?php echo $this->renderPartial('//manage/_sidebar',array('leagueTeams'=>$leagueTeams)); ?>
		</div>
	</div>
</div>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/global_render_teams.js"></script>
<script type="text/javascript">
	(function(a){

		a("#search_teams").click(function(){

			var data = {'name':$("#search_teams_input").val()};

			a.get(FBTOOLS.createUrl('Manage/searchTeamAjax'), data, function(result){

				if(!FBTOOLS.checkAjaxResult(result)){
					return;
				}

				if(result.status.code == 1000){
					var html = '';
					for(var i in result.data){
						html += Mustache.to_html(FBTEMPLATE.searchTeamList, result.data[i]);
					}

					a('#search_team_result').html(html);
				}

			}, 'json');

		});

		a(".search-result-wrap").delegate('.add-to-league','click',function(){
			var _this = a(this);
			a.ajax({
				type: 'POST',
				url: FBTOOLS.createUrl('League/addTeam'),
				data: {'leagueId':a(".main-content").data('leagueid'), 'teamId':a(this).data('teamid')},
				dataType: 'json',
				async: false,
				beforeSend: function () {

				},
				success: function (result) {
					if(!FBTOOLS.checkAjaxResult(result)){
						return;
					}
					FB.Global_rander_teams(result.data.leagueTeams);
					_this.text("已添加").addClass('disabled');
					console.log(result);
				}
			});
		});

		a("#invite_team").click(function(){

			var teamname = a("#invite_team_name").val();
			var mobilenum = a("#invite_captain_name").val();

			var regMobilenum = /^0?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}$/i;
			if (!regMobilenum.test(mobilenum)) {
				bootbox.alert('手机号码不合法！');
				return false;
			}

			var data = {'username':$("#invite_captain_name").val()};


			var regMobilenum = /^0?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}$/i;
			if (regMobilenum.test(mobilenum)) {
				a.get(FBTOOLS.createUrl('Manage/getUserTeams'), data, function(result){

					if(!FBTOOLS.checkAjaxResult(result)){
						return;
					}

					if(result.status.code == 1000){
						var rep = result.data.response;
						if(rep==undefined || rep=="" || rep==null || rep == "[]"){
							a("#invite_team_notice").hide();
							a("#invite_team").removeClass('disabled');
							a.ajax({
								type: 'POST',
								url: FBTOOLS.createUrl('League/inviteTeam'),
								data: {'teamname':teamname, 'mobilenum':mobilenum},
								dataType: 'json',
								async: false,
								beforeSend: function (){

								},
								success: function (result){
									if(!FBTOOLS.checkAjaxResult(result)){
										return false;
									}

									if(result.status.code == 1000 && result.data.response > 0){
										bootbox.alert('邀请短信已发出！');
									}else{
										bootbox.alert('操作有误！');
									}
								},
								error: function(result){
									alert('操作有误！');
								}
							});
						}else{
							var repArr = JSON.parse(rep);
							var teamStr = repArr.join(' ， ');
							a("#invite_in_team").html(teamStr);
							a("#invite_team_notice").show();
							a("#invite_team").addClass('disabled');
						}
						console.log(teamStr);
					}

				}, 'json');
			}else{
				return false;
			}





		});

		a("#invite_captain_name").blur(function(){
			a("#invite_team_notice").hide();
			a("#invite_team").removeClass('disabled');

//			var data = {'username':$("#invite_captain_name").val()};
//			var mobilenum = a("#invite_captain_name").val();
//
//			var regMobilenum = /^0?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}$/i;
//			if (regMobilenum.test(mobilenum)) {
//				a.get(FBTOOLS.createUrl('Manage/getUserTeams'), data, function(result){
//
//					if(!FBTOOLS.checkAjaxResult(result)){
//						return;
//					}
//
//					if(result.status.code == 1000){
//						var rep = result.data.response;
//						if(rep==undefined || rep=="" || rep==null){
//							a("#invite_team_notice").hide();
//							a("#invite_team").removeClass('disabled');
//						}else{
//							var repArr = JSON.parse(rep);
//							var teamStr = repArr.join(' ， ');
//							a("#invite_in_team").html(teamStr);
//							a("#invite_team_notice").show();
//							a("#invite_team").addClass('disabled');
//						}
////						console.log(teamStr);
//					}
//
//				}, 'json');
//			}else{
//				return false;
//			}

		});

	})(jQuery)
</script>