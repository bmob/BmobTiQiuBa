(function(a){

    a("#league-form").delegate("#add_playground",'click',function(){
        if(a(".playground").length < 5){
            a("#playground_field").append('<input type="text" id="LeagueModel_playground" name="LeagueModel[playground][]" placeholder="常用球场"  class="form-control playground"><br/>');
        }else{
            bootbox.alert("常用球场最多只能5个！");
        }
    });

//    a("#league-form").delegate('.playground','blur',function(){
//        var playground = '';
//        a(".playground").each(function(){
//            playground = playground+a(this).attr('value')+',';
//        });
//       a("#playground_arr").val(playground.substring(-1));
//    });

})(jQuery)
