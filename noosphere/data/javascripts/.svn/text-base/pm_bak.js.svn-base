hidden_div = $("<div></div>");
hidden_div.attr("id", "drop_div");

function findPos(obj) {
	var curleft = curtop = 0;
    do {
		curleft += obj.offsetLeft;
		curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
    return [curleft,curtop];
}

$().ready(function() {
	$("body").append(hidden_div);
	$(".dropdown").each(function(elem) {
	    $("#" + this.id).mouseenter(function(e) {
	        var id_num = this.id.split("menu")[1];
	        dropdown(this, id_num, e);
        });
        $("#" + this.id).mouseleave(function(e) {
            hidden_div.hide();
        });
    });
	hidden_div.hide();
});

function dropdown(link, id, e) {
    var ary = menu[+id];
    if (ary != undefined) {
        var links = "";
        
        hidden_div.empty();
        
        $.each(ary, function(i, target) {
            hidden_div.append(target);
        });
        /*
        hidden_div.css("left", e.pageX - 10 );
    	hidden_div.css("top", e.pageY + 10 );*/
    	
    	var pos = $(link).position();
    	
    	
    	hidden_div.css("left", pos.left );
    	hidden_div.css("top", pos.top + 10 );
    	
        hidden_div.show();
    }
    
}
