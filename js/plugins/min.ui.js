(function(){(function(a){return a.plugin(function(){var d,g,c,f,e,b;g=function(h,j){var i;j=a.extend({autoOpen:false,draggable:true},j);i=a(h).addClass("dialog");if(j.draggable){i.draggable()}if(j.autoOpen){i.show().center()}i.find("button.close, .close-button").bind("click touchstart",function(){i.hide();return false});return i};c=function(j,l){var n,m,i,k,h;l=a.extend({handleCSS:{}},l);l.handleCSS=a.extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},l.handleCSS);n=a(j);i=false;k=h=0;m=a.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}).css(l.handleCSS).bind("mousedown, touchstart",function(o){i=true;k||(k=o.pageX);h||(h=o.pageY);return false});a(document).bind("mousemove, touchmove",function(q){var p,o;if(i){p=q.pageX-k;o=q.pageY-h;n.transform({translate:[p,o]},0).trigger("drag",{dragObject:n});return false}}).bind("mouseup, touchend",function(o){var p;if(i){i=false;p=m.position()[0];return a(document.elementFromPoint(p.left,p.top-1)).trigger("drop",{dropObject:n})}});return n.addClass("draggable").css({position:"relative","padding-top":n.css("padding-top").map(Number.AtLeast(parseInt(l.handleCSS.height,10))).px().first()}.append(m))};f=function(h,j){var i,l,k;j=a.extend({change:null,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",reset:false},j);i=a(h).addClass("progress-bar");if(j.reset){l=i.css("background").first();k=i.css("color").first()}return i.zap("updateProgress",function(m){while(m<1){m*=100}if(m>=99.9&&j.reset){i.css({background:l,color:k})}else{i.css({background:"-webkit-gradient(linear, 0 0, "+(parseInt(m))+"% 0,\ncolor-stop(0, "+j.barColor+"),\ncolor-stop(0.98, "+j.barColor+"),\ncolor-stop(1.0, "+j.backgroundColor+"))",color:j.textColor})}if(a.is("function",j.change)){return j.change(m)}})};d=function(h,k){var i,j,l;k=a.extend({exclusive:false,sticky:false},k);j=a(h).addClass("accordion");l=null;i=function(r){var o,m,p,q;p=a(r).children().first().filter("*");if(p.len()!==2){throw Exception("accordion row requires 2 elements, not "+(p.len()))}q=p.eq(0).addClass("title");o=p.eq(1).addClass("body").hide();m=false;return q.click(function(){if(k.exclusive){j.find(".body").hide()}if(m){if(!k.sticky){o.hide().removeClass("visible");q.removeClass("selected").trigger("deselect");return m=false}else{o.show().addClass("visible");q.addClass("selected").trigger("select");return m=true}}else{o.show().addClass("visible");q.addClass("selected").trigger("select");return m=true}})};j.bind("DOMNodeInserted",function(m){var o,n;o=j.children().first().filter("*");n=a(m.target).parents().first();return i(n.intersect(o))});j.children().first().filter("*").map(i);return j};b=function(h,l){var o,i,k,n,m;i=a(h).css({position:"relative",top:"0px",left:"0px"}.hide().map(a));o=0;i[o].show();i.next=function(){i[o].hide();o=++o%i.length;return i[o].show()};i.activate=function(j){i[o].hide();o=j;return i[j].show()};for(k=n=0,m=i.len();0<=m?n<m:n>m;k=0<=m?++n:--n){i[k].zap("_viewIndex",k).zap("activate",function(){return i.activate(this._viewIndex)})}return i};e=function(h,j){var l,n,k,m;k=a(h);j=a(j).viewStack();n=k.len();for(l=m=0;0<=n?m<=n:m>=n;l=0<=n?++m:--m){k._tabIndex=l}a(k[0]).addClass("active");return k.click(function(){k.removeClass("active");j.activate(this._tabIndex);return a(this).addClass("active")})};return{$:{UI:{Draggable:c,ProgressBar:f,ViewStack:b,Tabs:e,Accordion:d}},dialog:function(h){return g(this,h)},progressBar:function(h){return f(this,h)},viewStack:function(h){return b(this,h)},tabs:function(h){return e(this,h)},accordion:function(h){return d(this,h)},draggable:function(h){return c(this,h)}}})})(Bling)}).call(this);