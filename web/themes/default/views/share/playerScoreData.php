<?php $this->pageTitle="射手榜 － ".Yii::app()->name; ?>
<div class="container-fluid">
	<?php echo $this->renderPartial('//share/_banner'); ?>
	<div class="row fixed-zw"></div>
	<div class="row champion-cup">
		<div class="col-xs-12 text-center"><img src="<?php echo Yii::app()->params['themeAssetHost'] ?>images/share-champion-cup.png" width="90" height="90" class="autosize-img"><p class="champion-cup-name"><?php echo $leagueName ?></p></div>
	</div>
	<div class="row league-data">
		<div class="col-xs-12 p0">
			<div>
				<table class="col-xs-12 table-bordered table-striped p0">
					<?php $count = 1; foreach($playerRangeArr as $playerRange): ?>
						<?php
						if($count > 10){break;}
						?>
						<tr><td><?php echo $count; ?></td><td><?php echo $playerRange['name']; ?></td><td><?php echo $playerRange['team']; ?></td><td><?php echo $playerRange['totalGoals']; ?></td></tr>
						<?php $count++; endforeach; ?>
<!--					<tr><th>排名</th><th>球员</th><th>球队</th><th>进球</th></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
<!--					<tr><td>1</td><td>孙悟空</td><td>广州恒大</td><td>2</td></tr>-->
				</table>
			</div>
		</div>
	</div>
</div>
