<?php

	class LeagueModel extends CFormModel
	{

		public $name;
		public $city;
		public $playground;
		public $people;
		public $group_count;
		public $knockout;
		public $double_loop;
		public $notes;
		public $playgroundArr;
		private $bmobObj;

		/**
		 * Declares the validation rules.
		 * The rules state that username and password are required,
		 * and password needs to be authenticated.
		 */
		public function rules()
		{
			return array(
				// username and password are required
				array('name,city,playground,people,group_count,knockout,notes', 'required'),

			);
		}

		/**
		 * Declares attribute labels.
		 */
		public function attributeLabels()
		{
			return array(
				'name'=>'名称',
				'city'=>'城市',
				'playground'=>'常用球场',
				'people'=>'上场人数',
				'group_count'=>'小组数量',
				'knockout'=>'淘汰赛' ,
				'double_loop'=>'双循环',
				'notes'=>'规定',
			);
		}


		public function __construct(){
			parent::__construct();
			$this->bmobObj = new BmobObject("League");
			return $this->bmobObj;
		}

		/**
		 * @dese 查找用户创建的联赛
		 */
		public function findByMaster($masterId,$limit = ''){
			if($limit){
				$res = $this->bmobObj->get("",array('where={"master":"'.$masterId.'"}','limit='.$limit,'order=-createdAt'));
			}else{
				$res = $this->bmobObj->get("",array('where={"master":"'.$masterId.'"}','order=-createdAt'));
			}
			return $res->results;
		}

		/**
		 * 获取某个对象
		 * @param unknown_type $objectId
		 */
		public function get($objectId) {
			$res = $this->bmobObj->get($objectId);
			return $res;
		}

		/**
		 * @desc 创建一条记录
		 * @param $arr
		 * @return bool|mixed
		 */
		public function save($arr){
			foreach($arr as $k => $v){
				if($k == 'playground'){
					$arr[$k] = $v;
				}elseif($k == 'knockout'){
					$v == 0 ? $arr[$k] = false : $arr[$k] = true;
				}elseif($k == 'people' || $k == 'group_count'){
					$arr[$k] = intval($v);
				}
			}
			return $this->bmobObj->create($arr); //添加对象
		}

		/**
		 * @desc 更新一条记录
		 */
		public function update($id,$arr){
			foreach($arr as $k => $v){
				if($k == 'playground'){
					if(is_array($v)){
						foreach($v as $kp => $vp){
							if(empty($vp) || $vp == 'undefined'){
								unset($v[$kp]);
							}
						}
					}else{
						$v = array($v);
					}
					$arr[$k] = $v;
				}elseif($k == 'knockout' || $k == 'double_loop'){
					$v == 0 ? $arr[$k] = false : $arr[$k] = true;
				}elseif($k == 'people' || $k == 'group_count'){
					$arr[$k] = intval($v);
				}
			}
			return $this->bmobObj->update($id,$arr);
		}


		/**
		 * @desc 添加一条关联数据
		 */
		public function createRelation($colName,$table,$relId,$relToId){

			$defaultType = array("__type"=>"Pointer","className"=>"$table","objectId"=>"$relToId");

			//$dataJson = json_encode($defaultType);

			$data = array(
				"$colName" => array(
					"__op"=>"AddRelation",
					"objects"=>array($defaultType)
					//"objects"=>'[{"__type":"Pointer","className":"'.$table.'","objectId":"'.$teamid.'"}]'
				)
			);

			$res = $this->bmobObj->update($relId,$data);

			return $res;

		}

		/**
		 * @desc 删除一条关联数据
		 */
		public function removeRelation($colName,$table,$relId,$relToId){

			$defaultType = array("__type"=>"Pointer","className"=>"$table","objectId"=>"$relToId");

			//$dataJson = json_encode($defaultType);
			$data = array(
				"$colName" => array(
					"__op"=>"RemoveRelation",
					"objects"=>array($defaultType)
					//"objects"=>'[{"__type":"Pointer","className":"'.$table.'","objectId":"'.$teamid.'"}]'
				)
			);

			$res = $this->bmobObj->update($relId,$data);

			return $res;

		}

		/**
		 * @desc 给设备推送消息
		 */
		public function pushMsg(){

		}

		/**
		 *
		 */
		public function  allowEditLeague($masterId){
			$res = $this->findByMaster($masterId,1);
			if(empty($res)){
				Helper::flash('error', "你无权限编辑联赛信息（请确认你至少有一个联赛的管理权限）！", '/site/');
			}else{
				return $res;
			}
		}

	}

?>