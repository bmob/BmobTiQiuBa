
(function(a){

    FB = {

    };

    FBTOOLS = {

        trim:function(str){
            return str.replace(/(^\s*)|(\s*$)/g,
                "").replace(/(^\u3000*)|(\u3000*$)/g,"")
        },
        empty:function(str){
            return void 0===str||null===str||""===str
        },
        emptyObj:function(obj){
            for(var c in obj)return!1;
            return!0
        },

        //上下居中
        valignCenter: function(dom){
            var h = (a(window).height() - a(dom).height())/2;
            a(dom).css('margin-top',h-(h/10*2)+'px');
        },

        //大背景
        backStretch: function(dom){
            var resizeBg = function(){
                var wH = a(window).height();
                var wW = a(window).width();
                a(dom).css({
                    'height':wH,
                    'width':wW
                });
                a(dom).find('img').css({
                    'height':wH,
                    'width':wW
                });
            }
            a(window).load(resizeBg()).resize(resizeBg());
        },

        createUrl:function(route, params){
            var paramStr = '';

            for (var key in params) {
                paramStr += '&'+key+'='+params[key];
            };

            return FB.BASE_URL + '/' + route + paramStr;
        },

        checkAjaxResult:function(result){

            if(FBTOOLS.empty(result)){
                bootbox.alert(FBLANG.msgError);
                return false;
            }

            if(result.status.code != 1000){
                bootbox.alert(result.status.msg);
                return false;
            }

            return true;
        },

        editDialog: function(editBtn,dialog,title,callBack){
            a(editBtn).click(function(){
                var html = $(dialog+" form").clone();
                var _this = a(this)
                a(dialog+" form").remove();
                bootbox.dialog({
                    message:html,
                    title:title,
                    onEscape: function() {
                        a(dialog).html(html);
                    },
                    buttons: {
                        main: {
                            label: "确定",
                            className: "btn-primary",
                            callback: function(){
                                callBack(_this);
                                a(dialog).html(html);
                            }
                        }
                    }
                });
            });
        },

        regTest: function(reg, str){

            if (reg.test(str)){
                return true;
            }else{
                return false;
            }

        }

    }

    FBLANG = {
        msgTimeout:"服务器太忙了，请稍后再试哦。",
        msgError:"服务器太忙了，请稍后再试哦。",
        msgNoLogin:"您还没有登录",
        msgDenied:"对不起， 你没有权限做此项操作"
    };

    FBTEMPLATE = {

        searchTeamList: '<li class="search-result-row"><table ><tr><td style="text-align: left"><%name%></td><td rowspan="2" style="text-align: right"><button class="btn btn-info btn-xs add-to-league <%#hasLeague%>disabled<%/hasLeague%>" data-teamid="<%objectId%>"><%#hasLeague%>已添加<%/hasLeague%><%^hasLeague%>添加至联赛<%/hasLeague%></button></td></tr><tr><td style="text-align: left"><%cityname%> / 队长：<%captName%></td></tr></table></li>',
        leagueTeams:'<ul class="clearfix"><li><%name%></li><li><div class="pull-left"><i class="fa fa-check-circle color-success"></i><span class="register-status">未注册</span></div><a class="pull-right color-warning del-league-team" data-teamid="<%objectId%>">删除</a></li></ul>',

        newBookPaper:'<oi class=""><div class="chapter-section" bpid="{bpid}"><div class="section-label pull-left"><label class="control-label paper-index">第1卷名称：</label></div><div class="pull-left section-field" ><input type="text" class="form-control" name="" value="{name}"></div><div class=" tools hide"><span class="glyphicon glyphicon-plus add-new-chapter-section-btn" title="添加新卷"></span><span class="glyphicon glyphicon-trash remove-chapter-section-btn" title="删除卷"></span></div></div></oi>',
        newBookChapter:'<div class=""><div class="chapter-section"><div class="chapter-section" bpid="{bpid}"><div class="pull-left"><label class="chapter-index">第1章名称：</label></div><div class="pull-left chapter-field"><input type="text"class="form-control"name=""value="{name}"></div><div class=" tools hide"><span class="glyphicon glyphicon-plus add-new-chapter-section-btn"title="添加新章节"></span><span class="glyphicon glyphicon-trash remove-chapter-section-btn"title="删除章节"></span><span class="glyphicon glyphicon-save add-child-section-btn" title="添加子卷"></span></div></div></div><ol class="list-group"></ol></div>',

        getKnowledgeList:'<ul><%#knowledge%><li class="<%classid%>"><div><a data-klid="<%klid%>" class="knlistbtn"></a><a data-klid="<%klid%>" class="knlist" title="<%klname%>"><%klname%></a></div></li><%/knowledge%></ul>',
        cart:'<table><tbody><tr valign="top" style="height:30px;"><th class="basket-summary">已选试题<span class="stnum stnum-style">（<%total_count%>）</span></th><th colspan="2"></th><th><a class="flushallst">全部清空</a></th></tr><%#subject_type_list%><tr><td><%name%></td><td><span class="outerbox" style="width:40px;height: 8px;"><span class="fillbg" style="width:<%width%>%;"></span></span></td><td class="td-num"><span class="stnum"><%count%></span></td><td><a class="flushtypest" data-typeid="<%id%>"><span class="glyphicon glyphicon-trash del-icon"></span></a></td></tr><%/subject_type_list%></tbody></table>',

        bookChapterTree:'<ul><%#tree%><li class="tree-open"><div><span class="chapter-switch-btn chapter-close"href="javascript:void(0)"><i class="fa fa-minus-square-o"></i></span><i class="fa fa-book"></i><a class=""href="javascript:void(0)"title="<%bpname%>"><%bpname%></a><ul class="child-ul"><%#children%><li class="tree-leaf"><div><i class="fa fa-building-o"></i><a data-bpid="<%bpid%>" class="chapter-paper-name paper-status<%status%> <%active%>" title="<%bpname%>"><%bpname%></a><span font-grey"><%name%></span><span class="paper-status-msg font-grey"><%msg%></span></div></li><%/children%></ul></div></li><%/tree%></ul>',
        studentKnowledge:'<%#nodes%><tr class="sub-node-<%parentklid%>" data-klid="<%klid%>" data-haschild="<%haschildklid%>"><td style="<%style%>"><span class="knowledge-node"><i class="fa <%icon%>"></i></span><span title="<%klname%>"><%klname%></span></td><td><span><%count%></span></td><td><div class="knowledge-progress"><span class="outerbox"><span class="fillbg"style="width:<%scale%>%;background-color:<%color%>"></span></span><span><%scale%>%</span></div></td><td><a class="down-error">下载</a><span class="cut-off-line" style="float: none;">|</span><a class="a-next show-error">显示</a></td><td><a class="down-varst">下载</a><span class="cut-off-line" style="float: none;">|</span><a class="a-next show-varst">显示</a></td></tr><%/nodes%>'
    }


    a(function(){
        FBTOOLS.valignCenter(".valign-center");
        FBTOOLS.backStretch(".back-stretch");
    });

})(jQuery);