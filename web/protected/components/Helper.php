<?php
class Helper
{

	/**
	 * 跳转中间页
	 * @param string $title error or notice or success 要css中定义flash-$title的class
	 * @param string $message 显示内容
	 * $param string $url 跳转的url
	 */
	public static function flash($title, $message, $url, $more_message = '', $second = 1)
	{
		Yii::app()->user->setflash('flash', array('title' => $title, 'content' => $message, 'url' => $url, 'more_content' => $more_message, 'second'=>$second));
		Yii::app()->controller->render('//site/error');
		exit;
	}

}