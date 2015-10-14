<?php $this->pageTitle="阵容 － ".Yii::app()->name; ?>

<style>
	.lineup-player ul li{}
	.lineup-player .lineup-player-person{padding: 0 5px;display: inline-block;color: #ffffff;}
	.lineup-player .lineup-player-person img{border-radius: 30px;}
	.lineup-back{position: absolute;top: 22%;width: 100%;}
	.lineup-goalkeeper{position: absolute;top: 5%;width: 100%;}
	.lineup-striker{position: absolute;top: 46%;width: 100%;}
	.lineup-forword{position: absolute;top: 69%;width: 100%;}
</style>
<?php
// $backPlayers,
// $strikerPlayers,
// $forwardPlayers,
// $goalkeeperPlayers
?>

<div class="container-fluid">
	<?php echo $this->renderPartial('//share/_banner'); ?>
	<div class="row fixed-zw"></div>
	<div class="row">
		<div class="col-xs-12"><p class="pt10"><strong><?php echo $team->name ?></strong>队阵容</p></div>
	</div>
	<div class="row">
		<div class=" text-center  autosize-img-wrap" style="position: relative;margin: 0 auto;">
			<img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/playground-bg.png" class="autosize-img" width="652" height="933" />
			<div class="lineup-goalkeeper text-center lineup-player">
				<ul>
					<li>

						<div class="lineup-player-person">
							<img
								src="<?php
								if(isset($goalkeeperPlayers->avator->url) && !empty($goalkeeperPlayers->avator->url)){
									echo 'http://file.bmob.cn/'.$goalkeeperPlayers->avator->url;
								}else{
									echo Yii::app()->params['themeAssetHost'].'images/line-player.png';
								}
							?>"
							width="99"
							height="100"
							class="autosize-img" />
							<br/><span>
								<?php
									if(isset($goalkeeperPlayers->nickname)){
										echo $goalkeeperPlayers->nickname;
									}
								?>
							</span></div>
					</li>
				</ul>
			</div>
			<div class="lineup-back text-center lineup-player">
				<ul>
					<li>
						<?php foreach($backPlayers as $backPlayer): ?>
							<div class="lineup-player-person">
								<img
									src="<?php
									if(isset($backPlayer->avator->url) && !empty($backPlayer->avator->url)){
										echo 'http://file.bmob.cn/'.$backPlayer->avator->url;
									}else{
										echo Yii::app()->params['themeAssetHost'].'images/line-player.png';
									}
									?>"
									width="99"
									height="100"
									class="autosize-img" />
								<br/><span>
									<?php
										if(isset($backPlayer->nickname)){
											echo $backPlayer->nickname;
										}
									?>
								</span></div>
						<?php endforeach; ?>
					</li>
				</ul>
			</div>
			<div class="lineup-striker text-center lineup-player">
				<ul>
					<li>
						<?php foreach($strikerPlayers as $striker): ?>
							<div class="lineup-player-person">
								<img
									src="<?php
									if(isset($striker->avator->url) && !empty($striker->avator->url)){
										echo 'http://file.bmob.cn/'.$striker->avator->url;
									}else{
										echo Yii::app()->params['themeAssetHost'].'images/line-player.png';
									}
									?>"
									width="99"
									height="100"
									class="autosize-img" />
								<br/><span>
									<?php
									if(isset($striker->nickname)){
										echo $striker->nickname;
									}
									?>
								</span></div>
						<?php endforeach; ?>
					</li>
				</ul>
			</div>
			<div class="lineup-forword text-center lineup-player">
				<ul>
					<li>
						<?php foreach($forwardPlayers as $forward): ?>
							<div class="lineup-player-person">
								<img
									src="<?php
									if(isset($forward->avator->url) && !empty($forward->avator->url)){
										echo 'http://file.bmob.cn/'.$forward->avator->url;
									}else{
										echo Yii::app()->params['themeAssetHost'].'images/line-player.png';
									}
									?>"
									width="99"
									height="100"
									class="autosize-img" />
								<br/><span>
									<?php
									if(isset($forward->nickname)){
										echo $forward->nickname;
									}
									?>
								</span></div>
						<?php endforeach; ?>
					</li>
				</ul>
			</div>
		</div>
	</div>

</div>
