<?php $this->pageTitle="个人数据 － ".Yii::app()->name; ?>
<link rel="stylesheet" type="text/css" href="<?php echo Yii::app()->params['themeAssetHost'] ?>css/data_style.css">
<style>
	.positionrl{position: relative;}
	.wrap-left-top-n{padding: 10px;position: absolute;left:20px;top:20px;color: #ffffff;font-size: 25px;}
	.font-large-y{font-size: 60px;color: #f37900;}
	.swipe_tip { background: url(<?php echo Yii::app()->params['themeAssetHost'] ?>images/arrow.png) no-repeat; background-size: cover; width: 25px; height: 25px; margin: 0 0 0 0px; position: absolute; left: 50%; bottom: 13px; z-index: 333; -webkit-animation: 2s fadeOutUp ease-in-out infinite; margin-left: -12px; }
@-webkit-keyframes fadeOutUp {
 0% {
 opacity: 1;
 -webkit-transform: translateY(0px);
 transform: translateY(0px);
}
 50% {
 opacity: 0.3;
 -webkit-transform: translateY(-15px);
 transform: translateY(-15px);
}
}

</style>
<?php

	if(property_exists($userData, "nickname")){
		$userName = $userData->nickname;
	}else{
		$userName = '该球员';
	}

	if(property_exists($userData, "games")){
		$games = $userData->games;
	}else{
		$games = '未知';
	}

	if(property_exists($userData, "assists")){
		$assists = $userData->assists;
	}else{
		$assists = '未知';
	}

	
	if(property_exists($userData, "goals")){
		$goals = $userData->goals;
	}else{
		$goals = '未知';
	}

	if(property_exists($userData, "score")){
		$score = $userData->score;
	}else{
		$score = '未知';
	}
	
	
	

?>
<!--<div class="container-fluid">-->
<!--	--><?php //echo $this->renderPartial('//share/_banner'); ?>
<!--	<div class="row fixed-zw"></div>-->
<!---->
<!--	<div class="row">-->
<!--		<div class="positionrl">-->
<!--			<img src="--><?php //echo Yii::app()->params['themeAssetHost'] ?><!--images/playground-blue-man.png" class="autosize-img" width="720" height="1046"/>-->
<!--			<div class="wrap-left-top-n">-->
<!--				<p>自从2014年以来，<br/>--><?php //echo $userName ?><!--总共-->
<!--					<br/>参加<span class="font-large-y">--><?php //echo $games ?><!--</span>场比赛-->
<!--					<br/>完成<span class="font-large-y">--><?php //echo $assists ?><!--</span>次助攻-->
<!--					<br/>打进<span class="font-large-y">--><?php //echo $goals ?><!--</span>球-->
<!--					<br/>平均得分<span class="font-large-y">--><?php //echo $score ?><!--</span>-->
<!--				</p>-->
<!--			</div>-->
<!--		</div>-->
<!--	</div>-->
<!--</div>-->

<!-- personal group page -->
<div class="global">
	<div class="screen">
		<!-- page1 -->
		<div class="layout" data-index="1">
			<div class="swipe_tip"></div>
			<div class="ps-imglay"><a href="/share/download"><img class="sharepic" src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/download.png"/></a></div>
			<div class="ps-imglay">
				<div class="img-txt">自从2014年以来，<br>
					煤球王总共参加了<br>
					<b><?php echo $games ?></b>场比赛</div>
				<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/person01.png"/></div>
		</div>
		<!-- // page1 // -->
		<!-- page2 -->
		<div class="layout" data-index="2">
			<div class="swipe_tip"></div>
			<div class="ps-imglay"><a href="/share/download"><img class="sharepic" src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/download.png"/></a></div>
			<div class="ps-imglay">
				<div class="img-txt"><?php echo $userName?><br>
					总共打进了<br>
					<b><?php echo $goals ?></b>球</div>
				<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/person02.png"/></div>
		</div>
		<!-- // page2 // -->
		<!-- page3 -->
		<div class="layout" data-index="3">
			<div class="swipe_tip"></div>
			<div class="ps-imglay"><a href="/share/download"><img class="sharepic" src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/download.png"/></a></div>
			<div class="ps-imglay">
				<div class="img-txt"><?php echo $userName?><br>
					总共完成<br>
					<b><?php echo $assists ?></b>次助功</div>
				<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/person03.png"/></div>
		</div>
		<!-- // page3 // -->
		<!-- page4 -->
		<div class="layout" data-index="4">
			<div class="ps-imglay"><a href="/share/download"><img class="sharepic" src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/download.png"/></a></div>
			<div class="ps-imglay">
				<div class="img-txt">他的平均得分是<br>
					<b><?php echo $score ?></b></div>
				<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/person02.png"/></div>
		</div>
		<!-- // page4 // -->
		<!-- page5 -->
	</div>
</div>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/zepto.min.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/touch.js"></script>
<script type="text/javascript">
	var UA = function(){
		var userAgent = navigator.userAgent.toLowerCase();
		return {
			ipad: /ipad/.test(userAgent),
			iphone: /iphone/.test(userAgent),
			android: /android/.test(userAgent),
			weixin: /micromessenger/.test(userAgent),
			qqnews_version: userAgent.match(/qqnews/i) == "qqnews" ? userAgent.split('qqnews/')[1] : ''
		};
	}
	function compareVersions(v1, comparator, v2) {
		comparator = comparator == '=' ? '==' : comparator;
		var v1parts = v1.split('.'), v2parts = v2.split('.');
		var maxLen = Math.max(v1parts.length, v2parts.length);
		var part1, part2;
		var cmp = 0;
		for(var i = 0; i < maxLen && !cmp; i++) {
			part1 = parseInt(v1parts[i], 10) || 0;
			part2 = parseInt(v2parts[i], 10) || 0;
			if(part1 < part2)
				cmp = 1;
			if(part1 > part2)
				cmp = -1;
		}
		return eval('0' + comparator + cmp);
	}
	var Layout = {
		isScrll : true,
		page: function (i, _h){
			$(".global").css({ "-webkit-transform": "translate3d(0px, -" + _h * i +"px, 0px)" });
		},
		swipe: function(_h, _len){
			var _this = this;
			$(".layout").each(function(index, obj){
				$(obj).on("swipeUp", function(){
					if (_this.isScrll &&  index < (_len - 1)) {
						_this.page(index + 1, _h);
					}
				}).on("swipeDown", function(){
						_this.page(index - 1, _h);
					});
			});
		},
		init: function(){
			var _this = this,
				_w = $(window).width(),
				_h = $(window).height(),
				_len = $(".layout").length,
				m_pageh = _h;
			var ua = UA();
			if (_h < 500) {
				if (_h > 420) {
					$("body").addClass("midscrn")
				}else{
					$("body").addClass("smscrn")
				}

			}
			$(".global").width( _w ).height( _h * _len ).addClass("ease");
			$(".screen").width( _w ).height( _h * _len );
			$(".layout").css({"width":_w ,"height":_h});
			_this.page(0, _h);
			_this.swipe(_h, _len);

			$("#pageback").bind("click",function(){
				_this.page(0, _h);
			});
		}
	}
	Layout.init();
</script>
