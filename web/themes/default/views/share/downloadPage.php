<?php $this->pageTitle="应用下载 － ".Yii::app()->name; ?>

<style type="text/css">
	body{color: #eef0f2;height: 100%;}
	.download-btn-wrap{padding: 30% 0 20%;text-align: center;}
	.download-btn-wrap .download-btn{margin: 0 auto;width: 60%;}
	.download-btn-wrap a{display:block;width:100%;height:40px;line-height:40px;text-align:center;color:#ffffff;background: #ed7000;}
	.mt-50{margin-top: 50px;}
</style>
<div id="browse" class="container-fluid">
	<?php echo $this->renderPartial('//share/_banner'); ?>
	<div class="row fixed-zw"></div>

	<div></div>
	<div  class="row">
		<div class="download-btn-wrap col-xs-12">
			
			<div  class="download-btn">
				<ul>
					<li>
						<a href="/download/android.apk" class="col-xs-8">Android下载</a>
					</li>
					<li>
						<a class="col-xs-8 mt-50" href="https://itunes.apple.com/cn/app/ti-qiu-ba/id980206579?mt=8">iOS下载</a>
					</li>
				</ul>
			</div>
			
		</div>
	</div>
</div>
<div id="weixin">
				<img width="99%"  src = '/themes/default/assets/images/weixin.png'/>
</div>
<script type="text/javascript">
window.onload = function(){
    if(isWeiXin()){
     
       document.getElementById("browse").style.display = "none";
       document.getElementById("weixin").style.display = "";
    }else{
       document.getElementById("browse").style.display = "";
       document.getElementById("weixin").style.display = "none";
    }
    
}
function isWeiXin(){
    var ua = window.navigator.userAgent.toLowerCase();
    if(ua.match(/MicroMessenger/i) == 'micromessenger' && ua.match(/android/i) == 'android' ){
        return true;
    }else{
        return false;
    }
}
</script>