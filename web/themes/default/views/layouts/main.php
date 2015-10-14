<?php /* @var $this Controller */ ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<title><?php echo CHtml::encode($this->pageTitle); ?></title>
	<!-- CSS Global Compulsory-->
	<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>bootstrap/css/bootstrap.min.css" />
	<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/font-awesome.min.css" />
	<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/style.css" />
	<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/global.css" />
	<!-- CSS Global Compulsory-->
	<?php

	$cs=Yii::app()->clientScript;
	$cs->scriptMap=array(
		'jquery.js' => Yii::app()->params['themeAssetHost'].'js/lib/jquery-1.10.2.min.js',
		'jquery.min.js' => Yii::app()->params['themeAssetHost'].'js/lib/jquery-1.10.2.min.js',
	);

	$cs->registerCoreScript('jquery');

	?>
	<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>bootstrap/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>bootstrap/js/bootbox.js"></script>
	<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/common.js"></script>
	<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/mustache.js"></script>
	<!--用户信息-->
	<script>
		FB.BASE_URL = "<?php echo Yii::app()->getRequest()->getBaseUrl(TRUE)?>";
	</script>
	<!-- JS Implementing Plugins -->

	<!--[if lt IE 9]>
	<script src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/html5shiv.js"></script>
	<script src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/respond.js"></script>
	<![endif]-->
</head>

<body>
<?php echo $this->renderPartial('//layouts/_header'); ?>
<div class="" id="page">
	<?php echo $content; ?>
</div><!-- page -->

</body>

</html>
