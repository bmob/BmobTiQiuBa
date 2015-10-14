<?php $this->pageTitle="基本信息 － ".Yii::app()->name; ?>
<!--=== Msg Table ===-->
<div class="container valign-center">
	<?php if(isset($_GET['errMsg']) && !empty($_GET['errMsg']) && $result != 'success'): ?>
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<div class="alert alert-danger" style="text-align: center"><?php echo $_GET['errMsg']; ?></div>
			</div>
		</div>
	<?php endif; ?>
	<div class="row">
		<div class="league-match-form col-md-8 col-md-offset-2">
			<div class="form-title"><h3 style="margin:0px 0 30px 0">完善联赛基本资料</h3></div>
			<?php

			$options=array('id'=>'league-form',
				'enableClientValidation'=>TRUE,
//				'enableAjaxValidation'=>TRUE,
				'clientOptions'=>array(
					'validateOnSubmit'=>TRUE
					//'validateOnChange'=>TRUE
				),
				'htmlOptions'=>array(
					'class'=>'form-horizontal',
				),
			);
			//$form->errorMessageCssClass = 'help-block error';
			$form = $this->beginWidget('CActiveForm', $options);

			?>
			    <?php echo $form->hiddenField($model,'leagueid',array('class'=>'form-control','value'=>$leagueList->objectId));?>
<!--				--><?php //echo $form->hiddenField($model,'playgroundArr',array('class'=>'form-control','id'=>'playground_arr'));?>
				<div class="form-group">
					<?php

						echo $form->labelEx($model,'name', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<?php
							if(isset($leagueList->name) && !empty($leagueList->name)){
								echo $form->textField($model,'name',array('class'=>'form-control','value'=>$leagueList->name));
							}else{
								echo $form->textField($model,'name',array('class'=>'form-control'));
							}
							echo $form->error($model, 'name', array());
						?>
					</div>
				</div>

				<div class="form-group">
					<?php
						echo $form->labelEx($model,'city', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<div id="city_3">
							<div class="row">
								<div class="col-sm-6">
									<select class="prov form-control col-sm-6" id="prov_name"></select>
								</div>
								<div class="col-sm-6">
									<select class="city form-control col-sm-6" id="city_name" disabled="disabled"></select>
								</div>
							</div>
						</div>
						<?php
							if(isset($leagueList->city) && !empty($leagueList->city)){
								echo $form->hiddenField($model,'city',array('class'=>'form-control','value'=>$leagueList->city));
							}else{
								echo $form->hiddenField($model,'city',array('class'=>'form-control','value'=>'440100'));
							}
							echo $form->error($model, 'city', array());
						?>
					</div>
				</div>
				<div class="form-group">
					<?php
						echo $form->labelEx($model,'playground', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-9" id="playground_field">
						<?php
							if(isset($leagueList->playground) && !empty($leagueList->playground)){
//								$leagueList = CommonFunction::ob2ar($leagueList);
//								var_dump($leagueList);
								foreach($leagueList->playground as $v){
									echo $form->textField($model,'playground[]',array('class'=>'form-control playground','value'=>$v));
									echo $form->error($model, 'playground', array())."<br/>";
								}
							}else{
								echo $form->textField($model,'playground[]',array('class'=>'form-control'));
								echo $form->error($model, 'playground', array());
							}

						?>
					</div>
					<div class="col-sm-1 input-plus-btn">
						<div class="btn btn-default dashed-btn" id="add_playground">
							<i class="fa fa-plus"></i>
						</div>
					</div>
				</div>
				<div class="form-group">
					<?php
						echo $form->labelEx($model,'people', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<?php
							if(isset($leagueList->people) && !empty($leagueList->people)){
								echo $form->textField($model,'people',array('class'=>'form-control','value'=>$leagueList->people));
							}else{
								echo $form->textField($model,'people',array('class'=>'form-control'));
							}
							echo $form->error($model, 'people', array());
						?>
					</div>
				</div>
				<div class="form-group">
					<?php
						echo $form->labelEx($model,'group_count', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<?php
							if(isset($leagueList->group_count) && !empty($leagueList->group_count)){
								echo $form->textField($model,'group_count',array('class'=>'form-control','value'=>$leagueList->group_count));
							}else{
								echo $form->textField($model,'group_count',array('class'=>'form-control'));
							}
							echo $form->error($model, 'group_count', array());
						?>
					</div>
				</div>
				<div class="form-group">
					<?php
						echo $form->labelEx($model,'knockout', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<?php
							if(isset($leagueList->knockout)){
								echo $form->dropDownList($model, 'knockout', array(1=>'有',0=>'无'), array('class'=>'form-control','options' => array($leagueList->knockout=>array('selected'=>true))));
							}else{
								echo $form->dropDownList($model, 'knockout', array(1=>'有',0=>'无'), array('class'=>'form-control'));
							}
							echo $form->error($model, 'knockout', array());
						?>

					</div>
				</div>

				<div class="form-group">
					<?php
					echo $form->labelEx($model,'double_loop', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<?php
						if(isset($leagueList->double_loop)){
							echo $form->dropDownList($model, 'double_loop', array(0=>'否',1=>'是'), array('class'=>'form-control','options' => array($leagueList->double_loop=>array('selected'=>true))));
						}else{
							echo $form->dropDownList($model, 'double_loop', array(0=>'否',1=>'是'), array('class'=>'form-control'));
						}
						echo $form->error($model, 'double_loop', array());
						?>

					</div>
				</div>

				<div class="form-group">
					<?php
						echo $form->labelEx($model,'notes', array('class'=>'col-sm-2 control-label'));
					?>
					<div class="col-sm-10">
						<?php
							if(isset($leagueList->notes) && !empty($leagueList->notes)){
								echo $form->textField($model,'notes',array('class'=>'form-control','value'=>$leagueList->notes));
							}else{
								echo $form->textField($model,'notes',array('class'=>'form-control'));
							}
							echo $form->error($model, 'notes', array());
						?>
					</div>
				</div>
				<div class="form-group">
					<div class="col-sm-offset-2 col-sm-10">
						<?php echo CHtml::submitButton('提交',array('class'=>'btn btn-primary','id'=>'submit_btn')); ?>
					</div>
				</div>
			<?php $this->endWidget(); ?>
		</div>
	</div>
</div>
<!--=== End Msg Table ===-->
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>js/leagueManage.js"></script>
<script type="text/javascript" src="<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/city/jquery.cityselect.js"></script>

<script type="text/javascript">
	FB.leagueUpdateResult = '<?php echo $result; ?>';
	FB.cityUrl = "<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/city/city.js";
	FB.cityJsonUrl = "<?php echo Yii::app()->params['themeAssetHost'] ?>plugins/city/citycode.js";
	$(function(){
		if(FB.leagueUpdateResult == 'success'){
			bootbox.alert("资料修改成功!");
		}

		var cityName = '广州';
		var cityNum = '';
		var cityJson = {};
		var provName = '';

		$.getJSON(FB.cityJsonUrl,function(json){
		 	cityJson = json.data;
			var cityInitCode = 	$("#LeagueModel_city").val();
			var cityInitName = '';
			for(var i in cityJson){
				if(cityJson[i].cityId == cityInitCode){
					cityInitName = cityJson[i].city_name;
					if(cityInitName != ''){
						$.getJSON(FB.cityUrl,function(jsonPro){
							var cityJsonPro = jsonPro.citylist;
							for(var j in cityJsonPro){
								var iprovName = cityJsonPro[j].p;
								var cityList = cityJsonPro[j].c;
								for(var z in cityList){
									if(cityList[z].n == cityInitName){
										provName = iprovName;
										$("#city_3").citySelect({
											prov:provName,
											city:cityInitName
										});
										break;
									}
								}
							}
						});

					}else{
						$("#city_3").citySelect({
							prov:"广东",
							city:"广州"
						});
					}
					$("#city_name").val(cityInitName);
				}
			}

		});

			$("#city_3").citySelect({
				prov:"广东",
				city:"广州"
			});


		$("#city_name").change(function(){

			cityName = $("#city_name").val();
			for(var i in cityJson){
				if(cityJson[i].city_name == cityName){
					cityNum = cityJson[i].cityId;
				}
			}

			$("#LeagueModel_city").val(cityNum);

		});

		$("#prov_name").change(function(){
			setTimeout(function(){
				$("#city_name").change();
			},1000)
		});

	});

</script>