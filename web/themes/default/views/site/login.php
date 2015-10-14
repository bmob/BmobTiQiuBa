

<!doctype html>
<html>
<head>
	<meta charset="UTF-8">
	<title>踢球吧</title>
	<meta name="viewport"content="width=device-width, initial-scale=1"/>
	<link rel="stylesheet" type="text/css" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/style_login.css">
</head>

<div class="screemPC">
	<!-- nav start -->
	<div class="nav">
		<nav class="boxInner"><a href="#"><span>首页</span></a><a href="#about"><span>关于我们</span></a><a href="#contact"><span>联系我们</span></a></nav>
	</div>
	<!-- header start-->
	<div class="header">
		<div class="boxInner">
			<div class="pro"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/pro.jpg" width="443" height="619" alt=""/></div>
			<div class="logoTxt">
				<h1><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/logotxt.jpg" width="402" height="313" alt="踢球吧"/></h1>
				<hgroup><a href="https://itunes.apple.com/cn/app/ti-qiu-ba/id980206579?mt=8" class="apple"><span class="iconApple"></span> iOS下载</a><a href="/download/android.apk" class="google"><span class="iconGoogle"></span>android下载</a></hgroup>
			</div>
		</div>
	</div>
	<!-- login box start -->
	<div class="loginBox" id="LoginBox">

			<?php
			$options=array('id'=>'login-form',
				'enableClientValidation'=>TRUE,
				'enableAjaxValidation'=>TRUE,
				'clientOptions'=>array(
					'validateOnSubmit'=>TRUE
				)
			);
			$form = $this->beginWidget('CActiveForm', $options);

			?>
			<h4>联赛管理系统  <p class="account-error-msg"><?php echo $form->error($model,'password') ?></p></h4>
			<div class="btn_Out">

				<div class="form-group" style="margin-bottom: 0px;">
					<label for="username" class="sr-only">
						<?php echo $form->textField($model,'username',array('class'=>'form-control','placeholder'=>'手机号码')) ?>
					</label>
				</div>
				<div class="form-group">
					<label for="password" class="sr-only">
						<?php echo $form->passwordField($model,'password',array('class'=>'form-control','placeholder'=>'密码')) ?>
					</label>
				</div>

				<label>
					<?php echo CHtml::submitButton('登 录',array('class'=>'confirmBtn')); ?>
				</label>
				<!--<button type="submit" class="btn btn-primary col-sm-12 col-md-12">登&nbsp;录</button>-->

			</div>
			<?php $this->endWidget(); ?>

	</div>
	<!-- pro introduction start -->
	<div class="pro_Intro">
		<div class="title">
			<h2><span>专为记录你的比赛！</span></h2>

			<p>我们是心里怀揣着对足球的热爱，身体流着不安现状的血液。<br>
				我们相信移动互联网能使身边的踢球者更出彩。
				</p>
		</div>
		<hr>
		<div class="proPoint point01">
			<h2>独创联赛信息系统</h2>
			<p>全开放平台对接各类足球赛事数据，赛程表、积分榜、射手榜“一键”生成，认证系统确保比分真实。</p>
		</div>
		<div class="proPoint point02">
			<h2>轻松管理球队</h2>
			<p>球队接纳新成员，约战新比赛，发布新阵容，创造新纪录，消息第一时间送达。</p>
		</div>
		<div class="proPoint point03">
			<h2>个人生涯全景</h2>
			<p>记录你的每一场比赛，分享你的每一个进球，帮你回忆足球生涯高光时刻。</p>
		</div>
	</div>
	<!-- about us start -->
	<div class="boxOuter aboutus" id="about">
		<div class="boxInner"> <span><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/aboutus.jpg" width="413" height="391" alt=""/></span>
			<div>
				<h3 class="Ltitle">关于我们</h3>
				<p>“踢球吧”是广州翔阳科技有限公司打造的首款运动数据记录应用。</p>
				<p>大演帽子戏法后，你是否为没人围观而落寞？现在想想，你还记得大学四年一共踢了多少场比赛？参加公司联赛，上哪儿去查积分榜、赛程表？难道业余足球就该如此苍白？</p>
				<p>改变这一片小小的世界，这正是我们推出“踢球吧”的初衷。</p>
				<p>我们是心里怀揣着对足球的热爱，身体流着不安现状的血液，大脑想着怎么把运动融入并丰富我们的生活的那一群人。我们相信移动互联网能使身边的踢球者更出彩。</p>
				<p>踢球吧，兄弟，让我们来记住你的精彩。</p>
			</div>
		</div>
	</div>
	<!-- contact us start -->
	<div class="boxInner contactUs" id="contact">
		<h3 class="Ltitle">联系我们</h3>
		<ul class="contactIcon">
			<li>微信公众号：体育社交</li>
			<li>微博号：体育社交</li>
			<li>Q群“足球管家”：366851162</li>
			<li>Phone：13560362140</li>
		</ul>
		<div class="tcode">
			<div> <span>扫描添加微信公众号</span> <img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/tcode.gif" width="220" height="220" alt=""/> </div>
			<div> <span>扫描添加微博</span> <img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/tcode.gif" width="220" height="220" alt=""/> </div>
		</div>
	</div>
	<!-- footer start -->
	<div class="footer"> © 2015-2016  广州翔阳科技有限公司  版权所有    粤ICP备14052389号-1s </div>
</div>
<div class="handled">
	<div class="phoneInner"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/Phonebanner.jpg" width="100%" alt=""/></div>
	<!-- login box start -->
	<div class="loginBox1">
		<?php
		$options=array('id'=>'login-form',
			'enableClientValidation'=>TRUE,
			'enableAjaxValidation'=>TRUE,
			'clientOptions'=>array(
				'validateOnSubmit'=>TRUE
			)
		);
		$form = $this->beginWidget('CActiveForm', $options);

		?>
		<h4>联赛管理系统  <p class="account-error-msg"><?php echo $form->error($model,'password') ?></p></h4>
		<div class="btn_Out1">

			<div class="form-group" style="margin-bottom: 0px;">
				<label for="username" class="sr-only">
					<?php echo $form->textField($model,'username',array('class'=>'form-control','placeholder'=>'手机号码')) ?>
				</label>
			</div>
			<div class="form-group">
				<label for="password" class="sr-only">
					<?php echo $form->passwordField($model,'password',array('class'=>'form-control','placeholder'=>'密码')) ?>
				</label>
			</div>

			<label>
				<?php echo CHtml::submitButton('登 录',array('class'=>'confirmBtn')); ?>
			</label>
			<!--<button type="submit" class="btn btn-primary col-sm-12 col-md-12">登&nbsp;录</button>-->

		</div>
		<?php $this->endWidget(); ?>

	</div>
	<div class="proIntro1" id="proIntro1">
		<hgroup>
			<div class="title">专为记录<br>
				你的比赛！
				<p>我们心里怀揣着对足球的热爱，身体流着不安现状的血液。我们相信移动互联网能使身边的踢球者更出彩。</p></div>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point003.gif" /><span>独创联赛信息系统</span><p>全开放平台对接各类足球赛事数据，赛程表、积分榜、射手榜“一键”生成，认证系统确保比分真实。</p></div>
		</hgroup>
		<hgroup>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point002.gif" /><span>轻松管理球队</span><p>球队接纳新成员，约战新比赛，发布新阵容，创造新纪录，消息第一时间送达。</p></div>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point001.gif" /><span>个人生涯全景</span><p>记录你的每一场比赛，分享你的每一个进球，帮你回忆足球生涯高光时刻。</p></div>
		</hgroup>
	</div>
	<div class="download">
		<hgroup>
			<div><a href="https://itunes.apple.com/cn/app/ti-qiu-ba/id980206579?mt=8"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point004.gif" /></a><span>iOS下载</span></div>
			<div><a href="/download/android.apk"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point005.gif" /></a><span>android下载</span></div>
		</hgroup>
	</div>
	<div class="greenC">
		<hgroup>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point006.gif" /><span>公众号：即将登场</span></div>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point007.gif" /><span>微博：＠踢球吧</span></div>
		</hgroup>
		<hgroup>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point008.gif" /><span>Q群“足球管家”：366851162</span></div>
			<div><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/point009.gif" /><span>Tel：Phone：13560362140</span></div>
		</hgroup>
	</div>
	<div class="footer"> © 2015-2016  广州翔阳科技有限公司  版权所有<br>
		粤ICP备14052389号-1s </div>
</div>
<script src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/lib/jquery-1.10.2.min.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		var IDTop = $("#LoginBox").offset().top;
		$(document).scroll(function(){
			$("#LoginBox").stop();
			var BodyTop = $(document).scrollTop();
			var newTop = BodyTop;
			if( BodyTop >= IDTop ){
				$("#LoginBox").animate({ top:newTop },400);
			}else if ( BodyTop < IDTop ){
				$("#LoginBox").animate({ top:622 },400);
			}
		});

		$("#proIntro1 > hgroup > div").click(function(){
			var cssDisplay = $("p", this).css("display");
			$("#proIntro1 > hgroup > div >p ").css("display", "none");
			if ( cssDisplay == "-webkit-box" ) {
				$("p", this).css("display", "none");
			} else {
				$("p", this).css("display", "-webkit-box");
			}
		});

	});
</script>
</body>
</html>
