(function(a){
    FB.Global_rander_teams = function(leagueTeams) {

        var html = ''
        for(var i in leagueTeams){
            html += Mustache.to_html(FBTEMPLATE.leagueTeams, leagueTeams[i]);
        }

        a('#team_list').html(html);
    }
})(jQuery)
