<!--=== Header ===-->
<div class="header container-fluid">

	<!--=== Header ===-->
	<div class="navbar navbar-default" role="navigation">
		<div class="container">
			<!-- Brand and toggle get grouped for better mobile display -->
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-responsive-collapse">
					<span class="sr-only">Toggle navigation</span>
					<span class="fa fa-bars"></span>
				</button>
				<a class="navbar-brand" href="/manage/leagueManage">
					<img id="logo-header" src="<?php echo Yii::app()->params['themeAssetHost']; ?>images/logo_site.png" alt="Logo">
				</a>
			</div>

			<!-- Menu -->
			<div class="collapse navbar-collapse navbar-responsive-collapse">
				<ul class="nav navbar-nav">
					<li class="<?php echo $this->action->id == 'leagueManage' ? 'active' : ''; ?>">
						<a href="/manage/leagueManage"><i class="fa fa-file-text"></i>基本信息</a>
					</li>
					<li class="<?php echo $this->action->id == 'teamManage' ? 'active' : ''; ?>">
						<a href="/manage/teamManage"><i class="fa fa-users"></i>参赛队管理</a>
					</li>
					<li class="<?php echo $this->action->id == 'schedule' ? 'active' : ''; ?>">
						<a href="/manage/schedule"><i class="fa fa-trophy"></i>赛程管理</a>
					</li>
					<li class="<?php echo $this->action->id == 'resultManage' ? 'active' : ''; ?>">
						<a href="/manage/resultManage"><i class="fa fa-info-circle"></i>赛果管理</a>
					</li>
					<li class="<?php echo $this->action->id == 'tongji' ? 'active' : ''; ?>">
						<a href="/manage/tongji"><i class="fa fa-signal"></i>数据统计</a>
					</li>
				</ul>
				<ul class="nav navbar-nav navbar-right" style="color: #ffffff">
					<?php if(Yii::app()->user->id): ?>
						<li class=""><p class="pull-left" style="padding-bottom: 25px;padding-top: 25px;margin:0px "><?php echo Yii::app()->user->id.''?></p><a  href="/site/logout">退出</a></li>
					<?php else: ?>
						<li class=""><a  href="/site/login">登录</a></li>
<!--						<li class=""><a  href="/login.html#/signup">注册</a></li>-->
					<?php endif; ?>
				</ul>

			</div><!--/navbar-collapse-->
		</div>
	</div>
	<!-- End Navbar -->
</div>
<!--=== End Header ===-->