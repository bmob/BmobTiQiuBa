<style>
	body{background: #ffffff;}
	.game-result-wrap{

	}
	.game-result-wrap ul{padding-left: 0px;}

</style>

<div class="container common-content">
	<div class="row">
		<div class="col-md-9">
			<div class="main-content">
				<div class="game-result-wrap">
					<div class="block-title cancle-line-bottom clearfix">
						<strong class="pull-left">比赛结果</strong>
					</div>
					<ul>
						<li class="row">

							<div class="col-md-2">山东鲁能</div>
							<div class="col-md-3">
								<div class="form-group">
									<div class="col-sm-12">
										<input type="text" class="form-control">
									</div>
								</div>
							</div>
							<div class="col-md-2">大白菜队</div>
							<div class="col-md-3">
								<div class="form-group">
									<div class="col-sm-12">
										<input type="text" class="form-control">
									</div>
								</div>
							</div>
							<div class="col-md-2">
								<div><i class="fa fa-minus-circle color-warning"></i>尚未认证</div>
							</div>
						</li>
						<li></li>
						<li></li>
						<li></li>

					</ul>
				</div>

			</div>
		</div>
		<div class="col-md-3">
			<?php echo $this->renderPartial('//manage/_sidebar'); ?>
		</div>
	</div>
</div>