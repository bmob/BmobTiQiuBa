<div class="sidebar sidebar-p">
	<strong class="sidebar-title">分组情况</strong>
	<?php $count = 1;  foreach($groupTeams as $group):?>
		<div class="g-name"><?php echo $count ?>组</div>
		<div class="team-list">
			<?php foreach($group as $team): ?>
				<ul class="clearfix">
					<li class="row"><div class="col-md-8"><?php echo $team->name; ?></div><div class="pull-right col-md-4" style="padding: 0px"><i class="fa fa-check-circle color-success"></i><span class="register-status">未注册</span></div></li>
				</ul>
			<?php endforeach; ?>
		</div>
		<?php $count++; endforeach; ?>
</div>