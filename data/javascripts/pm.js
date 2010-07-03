hidden_div = $("<div></div>");
hidden_div.attr("id", "drop_div");

hidden_div.mouseenter(function(e) {
    in_menu = true;
});

hidden_div.mouseleave(function(e) {
    in_menu = false;
    $(this).hide();
});

var in_menu = false;
var in_link = false;
var timeout = 200;

function hide_delay(hidden_div) {
    if (!in_menu && !in_link) hidden_div.hide();
}

$().ready(function() {
	$("body").append(hidden_div);
	$(".dropdown").each(function(elem) {
	    $("#" + this.id).mouseenter(function(e) {
	        in_menu = false;
	        in_link = true;
	        var id_num = this.id.split("menu")[1];
	        dropdown(this, id_num, e);
        });
        $("#" + this.id).mouseleave(function(e) {
            in_link = false;
            setTimeout("hide_delay(hidden_div)", timeout);
        });
    });
	hidden_div.hide();
});

function dropdown(link, id, e) {
    var ary = menu[+id];
    if (ary != undefined) {
        var links = "";
        
        hidden_div.empty();
        
        $("<div id='definition'>See definition at:</div>").appendTo(hidden_div);
        
        $.each(ary, function(i, target) {
            hidden_div.append(target);
        });
        /*
        hidden_div.css("left", e.pageX - 10 );
    	hidden_div.css("top", e.pageY + 10 );*/
    	
    	var link = $(link);
    	var pos = link.position();
    	
    	var win_width = $(window).width();
    	
    	if (pos.left + hidden_div.width() > win_width) {
    	    hidden_div.css("left", win_width - hidden_div.width() - 5);
	    } else {
	        hidden_div.css("left", pos.left);
        }
    	hidden_div.css("top", pos.top + 15 );
    	
        hidden_div.show();
    }
    
}
