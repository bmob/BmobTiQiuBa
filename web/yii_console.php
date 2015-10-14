<?php

// change the following paths if necessary
$yii=dirname(__FILE__).'/../yii/framework/yii.php';

// remove the following lines when in production mode
defined('YII_DEBUG') or define('YII_DEBUG',true);
defined('YII_TRACE_LEVEL') or define('YII_TRACE_LEVEL',3);

require_once($yii);

$config=dirname(__FILE__).'/protected/config/console.php';

Yii::createConsoleApplication($config)->run();

