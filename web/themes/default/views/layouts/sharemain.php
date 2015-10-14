
<!DOCTYPE html>
<html xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0,target-densitydpi=720,user-scalable=0">
	<meta name="language" content="en" />
	<meta name="format-detection" content="telephone=no">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="apple-mobile-web-app-status-bar-style" content="default">
	<title><?php echo CHtml::encode($this->pageTitle); ?></title>
	<!-- CSS Global Compulsory-->
	<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>bootstrap/css/bootstrap.min.css" />
	<link rel="stylesheet" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/share.css" />
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

	<!--[if lt IE 9]>
	<script src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/html5shiv.js"></script>
	<script src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/respond.js"></script>
	<![endif]-->
</head>

<body>
<div class="" id="page">
	<?php echo $content; ?>
</div><!-- page -->
<script src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/share_common.js"></script>
</body>

</html>
