<div class="sidebar">
	<strong class="sidebar-title">球队列表</strong>
	<div class="team-list" id="team_list">
		<?php foreach($leagueTeams as $team):?>
		<ul class="clearfix">
			<li><?php echo $team->name ?></li>
			<li><div class="pull-left">
					<i class="fa fa-check-circle color-success"></i>

					<span class="register-status">
						<?php
//							if(isset($team->isRegister) && $team->isRegister){
//								echo '已注册';
//							}else{
//								echo '未注册';
//							}
							echo '已邀请';
						?>
					</span>
				</div>
				<?php if(!CommonFunction::isGrouped()):?>
					<a class="pull-right color-warning del-league-team" data-teamid="<?php echo $team->objectId ?>">删除</a>
				<?php endif;?>
			</li>
		</ul>
		<?php endforeach ?>
	</div>
</div>

<script type="text/javascript">
	(function(a){
		a(".common-content").delegate('.del-league-team','click',function(){
			var _this = a(this);
			if(confirm("你确定要删除这支球队吗？")){
				a.ajax({
					type: 'POST',
					url: FBTOOLS.createUrl('league/deleteTeam'),
					data: {'leagueId':a(".main-content").data('leagueid'), 'teamId':_this.data('teamid')},
					dataType: 'json',
					async: false,
					success: function (reponse) {
						//console.log(reponse);
						if(!FBTOOLS.checkAjaxResult(reponse)){
							return;
						}

						if(reponse.status.code == 1000){
							bootbox.alert('删除球队成功！');
						}

						FB.Global_rander_teams(reponse.data.leagueTeams);
						console.log(reponse);
					},
					error: function(reponse){
						bootbox.alert('操作有误！');
					}
				});
			}
	//		bootbox.confirm("你确定删除该球队吗？", function(result2) {

	//		});

		});
	})(jQuery)
</script>