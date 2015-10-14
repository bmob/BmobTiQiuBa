<style>
	body{background: #ffffff;}

</style>
<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datepicker/datepicker3.css" />
<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datetimepicker/bootstrap-datetimepicker.css" />

<div class="container common-content">
	<div class="row">
		<div class="col-md-9 col-sm-9">
			<div class="main-content">
				<div class="edit-schedule-wrap">
					<div class="block-title clearfix">
						<strong class="pull-left">编辑赛程</strong>
						<button class="btn btn-primary pull-right">发布</button>
					</div>
					<div class="edit-schedule-block">
						<ul>
							<li class="clearfix">
								<div class="close-btn"><i class="close-circle-btn"></i></div>
								<table class="form-horizontal col-md-12 col-sm-12">
									<tr><td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">时间：</label>
												<div class="col-sm-9">
													<div class="input-group">
														<input type="text" class="form-control datepicker">
														<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
													</div>
												</div>
											</div>
										</td>
										<td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">地点：</label>
												<div class="col-sm-9">
													<input type="text" class="form-control"  >
												</div>
											</div>
										</td>
									</tr>
									<tr><td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">时刻：</label>
												<div class="col-sm-9">
													<div class="input-group">
														<input type="text" class="form-control timepicker">
														<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
													</div>
												</div>
											</div>
										</td>
										<td rowspan="2">
											<div class="">
												<div class="team-vs-block">小白菜队</div>
												<i class="vs-icon"></i>
												<div class="team-vs-block">老白菜队</div>
											</div>
										</td>
									</tr>
									<tr>
										<td>
											<div class="form-group">
												<label class="col-sm-3 control-label">性质：</label>
												<div class="col-sm-9">
													<input type="text" class="form-control"  >
												</div>
											</div>
										</td>
									</tr>
								</table>
							</li>

							<li class="clearfix">
								<div class="close-btn"><i class="close-circle-btn"></i></div>
								<table class="form-horizontal col-md-12 col-sm-12">
									<tr><td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">时间：</label>
												<div class="col-sm-9">
													<div class="input-group">
														<input type="text" class="form-control datepicker">
														<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
													</div>
												</div>
											</div>
										</td>
										<td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">地点：</label>
												<div class="col-sm-9">
													<input type="text" class="form-control"  >
												</div>
											</div>
										</td>
									</tr>
									<tr><td>
											<div class="form-group">
												<label  class="col-sm-3 control-label">时刻：</label>
												<div class="col-sm-9">
													<div class="input-group">
														<input type="text" class="form-control timepicker">
														<div class="input-group-addon"><i class="fa fa-calendar"></i></div>
													</div>
												</div>
											</div>
										</td>
										<td rowspan="2">
											<div class="">
												<div class="team-vs-block">小白菜队</div>
												<i class="vs-icon"></i>
												<div class="team-vs-block">老白菜队</div>
											</div>
										</td>
									</tr>
									<tr>
										<td>
											<div class="form-group">
												<label class="col-sm-3 control-label">性质：</label>
												<div class="col-sm-9">
													<input type="text" class="form-control"  >
												</div>
											</div>
										</td>
									</tr>
								</table>
							</li>

							<li class="common-full-width-btn">
								<i class="fa fa-plus fa-lg color-warning"></i>&nbsp;&nbsp;&nbsp;&nbsp;创建新赛程
							</li>
						</ul>
					</div>
				</div>
			</div>
		</div>
		<div class="col-md-3 col-sm-3">
			<div class="sidebar sidebar-p">
				<strong class="sidebar-title">分组情况</strong>
				<div class="g-name">A组</div>
				<div class="team-list">
					<ul class="clearfix">
						<li>大白菜队</li>
						<li><div class="pull-left"><i class="fa fa-check-circle color-success"></i><span class="register-status">未注册</span></div><a class="pull-right color-warning">删除</a></li>
					</ul>
					<ul class="clearfix cancle-line-top">
						<li>大白菜队</li>
						<li><div class="pull-left"><i class="fa fa-minus-circle color-warning"></i></i><span class="register-status">未注册</span></div><a class="pull-right color-warning">删除</a></li>
					</ul>
					<ul class="clearfix cancle-line-bottom">
						<li>大白菜队</li>
						<li><div class="pull-left"><i class="fa fa-check-circle color-success"></i><span class="register-status">未注册</span></div><a class="pull-right color-warning">删除</a></li>
					</ul>
				</div>
				<div class="g-name">B组</div>
				<div class="team-list">
					<ul class="clearfix">
						<li>大白菜队</li>
						<li><div class="pull-left"><i class="fa fa-check-circle color-success"></i><span class="register-status">未注册</span></div><a class="pull-right color-warning">删除</a></li>
					</ul>
					<ul class="clearfix cancle-line-top">
						<li>大白菜队</li>
						<li><div class="pull-left"><i class="fa fa-minus-circle color-warning"></i></i><span class="register-status">未注册</span></div><a class="pull-right color-warning">删除</a></li>
					</ul>
					<ul class="clearfix cancle-line-bottom">
						<li>大白菜队</li>
						<li><div class="pull-left"><i class="fa fa-check-circle color-success"></i><span class="register-status">未注册</span></div><a class="pull-right color-warning">删除</a></li>
					</ul>
				</div>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datepicker/bootstrap-datepicker.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datetimepicker/moment.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/bootstrap-datetimepicker/bootstrap-datetimepicker.min.js"></script>

<script type="text/javascript">
//	$('.datepicker-day').datepicker({
//		format: 'mm/dd/yyyy',
//		startDate: '-3d'
//	});
//	$('.datepicker-moment').datepicker({
//		format: 'HH:mm'
//	});

$('.datepicker').datetimepicker({
	pickTime: false
});

$('.timepicker').datetimepicker({
	pickDate: false
});

</script>