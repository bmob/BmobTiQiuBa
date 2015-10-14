<?php $this->pageTitle="分组管理 － ".Yii::app()->name; ?>

<style>
	body{background: #ffffff;}

</style>
<?php $leagueMsg = CommonFunction::ob2ar($leagueMsg) ?>
<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content">
				<div class="team-grouping-wrap">
					<div class="block-title clearfix">
						<strong class="pull-left">分组</strong>
					</div>
					<div class="team-grouping-block">
						<form action="<?php Yii::app()->createUrl('manage/grouping')  ?>" method="post">

							<?php if(isset($groupTeams) && !empty($groupTeams)): ?>

								<?php $count = 1;  foreach($groupTeams as $group): ?>
<!--									<input type="hidden" value="--><?php //echo $group[0]->objectId; ?><!--" name="TeamGroup[GroupId][]" />-->
									<table class="team-grouping">
										<tr><td><span class="team-grouping-title"><?php echo $count ?>组</span><input type="button" class="btn btn-primary select-group-team" value="选择球队" data-group="<?php echo $count ?>"></td></tr>
										<tr>
											<td>
												<div class="team-group-team-wrap" id="team_group_<?php echo $count ?>">
													<input type="hidden" value="" name="TeamGroup[<?php echo $count ?>][]" />
													<?php foreach($group as $team): ?>
														<div class="btn-group" data-teamid="<?php echo $team->objectId ?>">
															<input type="hidden" value="<?php echo $team->objectId ?>" name="TeamGroup[<?php echo $team->groupName ?>][]" />
															<button type="button" class="btn btn-success"><?php echo $team->name ?></button>
															<button type="button" class="btn btn-success delete-group-team" data-teamid="<?php echo $team->objectId ?>" style="padding: 3px 6px;"><i class="fa fa-times"></i></button>
														</div>
													<?php endforeach; ?>
												</div>
											</td>
										</tr>
									</table>
								<?php $count++; endforeach; ?>
							<?php else: ?>
								<?php  for($i = 1; $i <= $leagueMsg['group_count']; $i++): ?>
									<table class="team-grouping">
										<tr><td><span class="team-grouping-title"><?php echo $i ?>组</span><input type="button" class="btn btn-primary select-group-team" value="选择球队" data-group="<?php echo $i ?>"></td></tr>
										<tr>
											<td>
												<div class="team-group-team-wrap" id="team_group_<?php echo $i ?>">
													<div class="btn-group" data-teamid="">
														<input type="hidden" value="" name="TeamGroup[<?php echo $i ?>][]" />
													</div>
												</div>
											</td>
										</tr>
									</table>
								<?php endfor ?>
							<?php endif; ?>

							<div class="clearfix">
								<input type="submit" class="btn btn-primary" id="group_team_ok" value="确定分组"/>
								<p class="help-block">请确保分组无误，分组情况一旦确定则无法修改！</p>
							</div>

						</form>
					</div>
				</div>

			</div>
		</div>
		<div class="col-md-3">
			<?php echo $this->renderPartial('//manage/_sidebar',array('leagueTeams'=>$leagueTeams)); ?>
		</div>
	</div>
</div>
<div id="select_group_team" style="display: none">
	<form class="form-horizontal" id="form-select-team" role="form">
		<ul class="row">
			<?php $leagueTeams = CommonFunction::ob2ar($leagueTeams);foreach($leagueTeams as $team):?>
				<li class="col-md-4">
					<div class="checkbox">
						<label>
							<input type="checkbox" class="form-select-box" <?php if(isset($team["selected"])){echo 'disabled="disabled"  "status"="selected"' ;} ?> data-teamid="<?php echo $team["objectId"] ?>" data-teamname="<?php echo $team["name"] ?>"> <?php echo $team["name"] ?>
						</label>
					</div>
				</li>
			<?php endforeach ?>
		</ul>
	</form>
</div>

<script type="text/javascript">
	(function(a){

		//编辑应用更新信息
		FBTOOLS.editDialog(".select-group-team","#select_group_team","分组球队",function(_this){
			var groupId = _this.data("group");
			var html = a("#team_group_"+groupId).html();
			a("#form-select-team .form-select-box").each(function(){
				var teamId = a(this).data('teamid');
				var teamName = a(this).data('teamname');
				if(a(this).is(":checked") && !a(this).is('[status]') ){
					a(this).attr("disabled","disabled");
					a(this).attr("status","selected");
					//html += '<div class="btn btn-success" data-teamid="'+teamId+'">'+teamName+'</div>';
					html += '<div class="btn-group" data-teamid="'+teamId+'"><input type="hidden" value="'+teamId+'" name="TeamGroup['+groupId+'][]" /><button type="button" class="btn btn-success">'+teamName+'</button><button type="button" class="btn btn-success delete-group-team" data-teamid="'+teamId+'" style="padding: 3px 6px;"><i class="fa fa-times"></i></button></div>'
				}
			});
			a("#team_group_"+groupId).html(html);
		});

		a(".team-grouping-block").delegate('.delete-group-team','click',function(){
			var teamId = a(this).data('teamid');
			$("#select_group_team .form-select-box").each(function(){
				if(a(this).data('teamid') == teamId){
					a(this).removeAttr('disabled');
					a(this).removeAttr("checked");
					a(this).removeAttr("status");
				}
			});
			a(this).parent().remove();
		});

		a("form").submit(function(submit){
			if(confirm("你确定按此分组情况进行分组吗？")){
				return true;
			}else{
				submit.preventDefault();
				return false;
			}
		});

	})(jQuery)

</script>