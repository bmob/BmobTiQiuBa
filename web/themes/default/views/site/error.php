<?php $flash = Yii::app()->user->getFlash('flash');?>
<?php $this->pageTitle="出错啦！"?>
<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/page_404_error.css" >
<!--=== Breadcrumbs ===-->
<div class="row-fluid breadcrumbs margin-bottom-20">
	<div class="container">
		<h1 class="pull-left"></h1>
		<ul class="pull-right breadcrumb">
			<li></li>
		</ul>
	</div><!--/container-->
</div><!--/breadcrumbs-->
<!--=== End Breadcrumbs ===-->

<!--=== Content Part ===-->
<div class="container content">

	<div class="row">
		<div class="col-md-8 col-md-offset-2">
			<div class="error-v1">
				<span class="error-v1-title">:)</span>
				<span></span>
				<br />
				<p class="well well-sm">
					<?php if(empty($flash) && !empty(Yii::app()->user->id)): ?>
					对不起，你的操作有误！
					<?php else: ?>
						<?php if(empty(Yii::app()->user->id)): ?>
							你还未登录请先<a class="btn-u btn-bordered" href="/site/login">登录</a></p>
							<br />
						<?php else: ?>
							<?php echo $flash['content']; ?><br/>
						<?php endif; ?>
					<?php endif; ?>
				</p>

			</div>
		</div>
	</div>

</div><!--/container-->
<!--=== End Content Part ===-->
<!--<script type="text/javascript">-->
<!--    var i = --><?php //echo $second?><!--;-->
<!--    var intervalid;-->
<!--    intervalid = setInterval("printSecond()", 1000);-->
<!--    function printSecond() {-->
<!--        if (0 == i) {-->
<!--            window.location.href = document.getElementById("link").href;-->
<!--            clearInterval(intervalid);-->
<!--        }-->
<!--        document.getElementById("second").innerHTML = i;-->
<!--        i--;-->
<!--    }-->
<!--</script>-->
