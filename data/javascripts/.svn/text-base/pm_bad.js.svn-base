$().ready(function() {
	$(".dropdown").each(function(elem) {
	    $("#" + this.id).mouseenter(function(e) {
	        var id_num = this.id.split("menu")[1];
	        dropdown(this, id_num, e);
        });
        $("#" + this.id).mouseleave(function(e) {
            
        });
    });
});

function dropdown(link, id, e) {
    var ary = menu[+id];
    if (ary != undefined) {
        var links = "";
        
        hidden_div = $("<div></div>");
                
        $.each(ary, function(i, target) {
            hidden_div.append(target);
        });
        
        var link = $(link);
    	var pos = link.position();
    	
    	hidden_div.css("left", pos.left );
    	hidden_div.css("top", pos.top + 10 );
    	
        hidden_div.appendTo(link);
    }
    
}
