

    var autosize =	function(dom){

        var screenH = window.screen.availHeight
        var screenW = window.screen.availWidth

        var wD = screenW/720;
        var img = dom;
        img.each(function(){
     //       $(this).load(function(){
            if (navigator.userAgent.toLowerCase().match(/android/) && !navigator.userAgent.toLowerCase().match(/chrome\/38/)){

                if(wD == 1){
                    var t_wD = wD/2;
                }else if(wD == 1.5){
                    var t_wD = wD/3;
                }else{
                    var t_wD = wD;
                }
            }else{
                t_wD = wD
            }

            var imgWidth = $(this).width();
            var imgHeight = $(this).height();

            $(this).width(imgWidth*t_wD);
            $(this).height(imgHeight*t_wD);
            $(this).parent('.autosize-img-wrap').width(imgWidth*t_wD);
            $(this).parent('.autosize-img-wrap').height(imgHeight*t_wD);
            $(this).parent('.autosize-img-wrap').find('.autosize-wc-h').height(imgHeight*t_wD/2);
        //   });

        })

    }

    autosize($(".autosize-img"));

    $(".fixed-zw").height($(".logo-banner").height()+30);

