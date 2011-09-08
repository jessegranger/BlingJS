(function(){var l,s,A,q,o=Array.prototype.slice,C=Object.prototype.hasOwnProperty,D=function(a,j){function h(){this.constructor=a}for(var f in j)C.call(j,f)&&(a[f]=j[f]);h.prototype=j.prototype;a.prototype=new h;a.__super__=j.prototype;return a},B=function(a,j){return function(){return a.apply(j,arguments)}};!1 in document?alert("This browser is not supported"):(q=console&&console.log?function(){var a;a=1<=arguments.length?o.call(arguments,0):[];return console.log.apply(console,a)}:function(){var a;
a=1<=arguments.length?o.call(arguments,0):[];return alert(a.join(", "))},s=/,* +/,A=/\[object (\w+)\]/,l=function(a,j){var h;j==null&&(j=document);h=Object.Type(a);if(h==="undefined"||h==="null")h=[];else if(h==="array"||h==="bling"||h==="nodelist")h=a;else if(h==="node"||h==="window"||h==="function")h=[a];else if(h==="number")h=Array(a);else if(h==="string")if(a=a.trimLeft(),a[0]==="<")h=[l.HTML.parse(a)];else if(j.querySelectorAll)h=j.querySelectorAll(a);else throw Error("invalid context: "+j+" (type: "+
Object.Type(j)+")");else throw Error("invalid selector: "+a+" (type: "+Object.Type(a)+")");h.constructor=l;h.__proto__=l.fn;h.selector=a;h.context=j;h.length=h.len();return h},l.fn=[],Object.Keys=function(a,j){var h,f,e;j==null&&(j=!1);e=[];f=0;for(h in a)if(j||a.hasOwnProperty(h))e[f++]=h;return e},Object.Extend=function(a,j,h){var f,e,b;if(Object.prototype.toString.apply(h)==="[object Array]")for(f in h)j[h[f]]!==void 0&&(a[h[f]]=j[h[f]]);else{b=Object.Keys(j);for(h=0,e=b.length;h<e;h++)f=b[h],
a[f]=j[f]}return a},Object.Extend(Object,{Type:function(a){var j;switch(!0){case a===void 0:return"undefined";case a===null:return"null";case Object.IsString(a):return"string";case Object.IsType(a,l):return"bling";case Object.IsArray(a):return"array";case Object.IsType(a,NodeList):return"nodelist";case Object.IsNumber(a):return"number";case Object.IsFragment(a):return"fragment";case Object.IsNode(a):return"node";case Object.IsFunc(a):return"function";case Object.IsType(a,"RegExp"):return"regexp";
case (j=String(a))==="true"||j==="false":return"boolean";case Object.IsError(a):return"error";case Object.IsObject(a):return"setInterval"in a?"window":"object"}},IsType:function(a,j){return a===null?a===j:a.constructor===j?!0:typeof j==="string"?a.constructor.name===j||Object.prototype.toString.apply(a).replace(A,"$1")===j:Object.IsType(a.__proto__,j)},IsString:function(a){return a!=null&&(typeof a==="string"||Object.IsType(a,String))},IsNumber:function(a){return a!=null&&Object.IsType(a,Number)},
IsBoolean:function(a){return typeof a==="boolean"},IsFunc:function(a){return a!=null&&(typeof a==="function"||Object.IsType(a,Function))&&a.call!=null},IsNode:function(a){return a!=null&&a.nodeType>0},IsFragment:function(a){return a!=null&&a.nodeType===11},IsArray:function(a){return a!=null&&(Object.ToString(a)==="[object Array]"||Object.IsType(a,Array))},IsBling:function(a){return a!=null&&Object.IsType(a,l)},IsError:function(a){var j;return a!=null&&((j=a.constructor)!=null?j.name:void 0)==="Error"},
IsObject:function(a){return a!=null&&typeof a==="object"},IsDefined:function(a){return a!=null},Unbox:function(a){if(a!=null&&Object.IsObject(a)){if(Object.IsString(a))return a.toString();if(Object.IsNumber(a))return Number(a)}return a},ToString:function(a){return Object.prototype.toString.apply(a)}}),Object.Extend(Function,{Empty:function(){},Bound:function(a,j,h){var f;h==null&&(h=[]);"bind"in a?(h.splice(0,0,j),f=a.bind.apply(a,h)):f=function(){1<=arguments.length&&o.call(arguments,0);return a.apply(j,
h)};f.toString=function(){return"bound-method of "+j+"."+a.name};return f},Trace:function(a,j,h){var f;h==null&&(h=q);f=function(){var e;e=1<=arguments.length?o.call(arguments,0):[];h(""+(this.name||Object.Type(this))+"."+(j||a.name)+"(",e,")");return a.apply(this,e)};h("Function.Trace: "+(j||a.name)+" created.");f.toString=a.toString;return f},NotNull:function(a){return a!==null},IndexFound:function(a){return a>-1},ReduceAnd:function(a){return a&&this},UpperLimit:function(a){return function(j){return Math.min(a,
j)}},LowerLimit:function(a){return function(j){return Math.max(a,j)}},Px:function(a){return function(){return Number.Px(this,a)}}}),Object.Extend(Array,{Coalesce:function(){var a,j,h,f;a=1<=arguments.length?o.call(arguments,0):[];if(Object.IsArray(a[0]))return Array.Coalesce.apply(Array,a[0]);else for(h=0,f=a.length;h<f;h++)if(j=a[h],j!=null)return j},Extend:function(a,j){var h,f,e,b;f=a.length;for(e=0,b=j.length;e<b;e++)h=j[e],a[f++]=h;return a}}),Object.Extend(Number,{Px:function(a,j){j==null&&
(j=0);return a!=null&&parseInt(a,10)+(j|0)+"px"},AtLeast:function(a){return function(j){return Math.max(parseFloat(j||0),a)}},AtMost:function(a){return function(j){return Math.min(parseFloat(j||0),a)}}}),Object.Extend(String,{PadLeft:function(a,j,h){for(h==null&&(h=" ");a.length<j;)a=h+a;return a},PadRight:function(a,j,h){for(h==null&&(h=" ");a.length<j;)a+=h;return a},Splice:function(a,j,h,f){var e;e=a.length;h<0&&(h+=e);j<0&&(j+=e);return a.substring(0,j)+f+a.substring(h)},Checksum:function(a){var j,
h,f,e;j=1;h=0;for(f=0,e=a.length;0<=e?f<e:f>e;0<=e?f++:f--)j=(j+a.charCodeAt(f))%65521,h=(h+j)%65521;return h<<16|j}}),Object.Extend(Event,{Cancel:function(a){a.stopPropagation();a.preventDefault();a.cancelBubble=!0;return a.returnValue=!1},Prevent:function(a){return a.preventDefault()},Stop:function(a){a.stopPropagation();return a.cancelBubble=!0}}),function(a){a.plugins=[];a.plugin=function(j){var h,f;try{h=j.name;f=j.call(a,a);h=h||f.name;if(!h)throw Error("plugin requires a 'name'");a.plugins.push(h);
a.plugins[h]=f;delete f.name;f[l.symbol]&&(Object.Extend(l,f[l.symbol]),delete f[l.symbol]);return Object.Extend(l.fn,f)}catch(e){throw q("failed to load plugin "+h),e;}};a.plugin(function(){var j;j=null;a.__defineSetter__("symbol",function(a){j in window&&delete window[j];j=a;return window[a]=l});a.__defineGetter__("symbol",function(){return j});a.symbol="$";window.Bling=l;return{name:"Symbol"}});a.plugin(function(){var a,h,f;a=/^\s+/;String.prototype.trimLeft=Array.Coalesce(String.prototype.trimLeft,
function(){return this.replace(a,"")});String.prototype.split=Array.Coalesce(String.prototype.split,function(a){var b,c,i,g;b=[];for(c=g=0;(i=this.indexOf(a,c))>-1;)b[g++]=this.substring(c+1,i+1),c=i+1;return b});Array.prototype.join=Array.Coalesce(Array.prototype.join,function(a){var b,c;a==null&&(a="");b=this.length;if(b===0)return"";for(c=this[b-1];--b>0;)c=this[b-1]+a+c;return c});Element.prototype.matchesSelector=Array.Coalesce(Element.prototype.webkitMatchesSelector,Element.prototype.mozMatchesSelector,
Element.prototype.matchesSelector);f=Element.prototype.toString;Element.prototype.toString=function(a){return a?(a=this.nodeName.toLowerCase(),this.id!=null?a+="#"+this.id:this.className!=null&&(a+="."+this.className.split(" ").join(".")),a):f.apply(this)};if(Element.prototype.cloneNode.length===0)h=Element.prototype.cloneNode,Element.prototype.cloneNode=function(a){var b,c,i,g;a==null&&(a=!1);b=h.call(this);if(a){g=this.childNodes;for(c=0,i=g.length;c<i;c++)a=g[c],b.appendChild(a.cloneNode(!0))}return b};
return{name:"Compat"}});a.plugin(function(){var j,h,f;h=new (function(){function a(){var e;e=B(function(){if(this.length>0)return this.shift()()},this);this.schedule=B(function(a,i){var g,d;if(!Object.IsFunc(a))throw Error("function expected, got: "+typeof a);d=this.length;a.order=i+(new Date).getTime();if(d===0||a.order>this[d-1].order)this.push(a);else for(g=0;0<=d?g<d:g>d;0<=d?g++:g--)if(this[g].order>a.order){this.splice(g,0,a);break}setTimeout(e,i);return this},this)}D(a,Array);return a}());
j=function(a){return function(){var b;b=this[a];return Object.IsFunc(b)?Function.Bound(b,this):b}};f=function(a){var b;b=a.indexOf(".");return b>-1?this.zip(a.substr(0,b)).zip(a.substr(b+1)):this.map(j(a))};return{name:"Core",$:{log:q,delay:function(a,b){b&&h.schedule(b,a);return null}},eq:function(e){var b;b=a([this[e]]);b.context=this;b.selector=function(){return b.context.eq(e)};return b},each:function(a){var b,c,i;for(c=0,i=this.length;c<i;c++)b=this[c],a.call(b,b);return this},map:function(e){var b,
c,i,g;b=a();b.context=this;b.selector=function(){return b.context.map(e)};i=this.len();for(c=0;0<=i?c<i:c>i;0<=i?c++:c--){g=this[c];try{b[c]=e.call(g,g)}catch(d){b[c]=d}}return b},reduce:function(a,b){var c,i;c=b;i=this;b==null&&(c=this[0],i=this.skip(1));i.each(function(){return c=a.call(this,c,this)});return c},union:function(e,b){var c,i,g,d;g=a();d=c=i=0;g.context=this;for(g.selector=function(){return g.context.union(e,b)};d=this[i++];)g.contains(d,b)||(g[c++]=d);for(i=0;d=e[i++];)g.contains(d,
b)||(g[c++]=d);return g},intersect:function(e){var b,c,i,g,d,m;m=a();i=0;g=this.len();d=Object.IsFunc(e.len)?e.len():e.length;m.context=this;m.selector=function(){return m.context.intersect(e)};for(b=0;0<=g?b<g:b>g;0<=g?b++:b--)for(c=0;0<=d?c<d:c>d;0<=d?c++:c--)if(this[b]===e[c]){m[i++]=this[b];break}return m},distinct:function(a){return this.union(this,a)},contains:function(a,b){var c,i,g;for(i=0,g=this.length;i<g;i++)if(c=this[i],b&&c===a||!b&&c===a)return!0;return!1},count:function(a,b){var c;
if(a===void 0)return this.len();c=0;this.each(function(i){if(b&&i===a||!b&&i===a)return c++});return c},zip:function(){var e,b,c,i,g,d,m,h;e=1<=arguments.length?o.call(arguments,0):[];d=e.length;switch(d){case 0:return a();case 1:return f.call(this,e[0]);default:h={};m=this.len();g=a();for(b=c=0;0<=d?b<d:b>d;0<=d?b++:b--)h[e[b]]=f.call(this,e[b]);for(b=0;0<=m?b<m:b>m;0<=m?b++:b--){e={};for(i in h)e[i]=h[i].shift();g[c++]=e}return g}},zap:function(a,b){var c;c=a.indexOf(".");return c>-1?this.zip(a.substr(0,
c)).zap(a.substr(c+1),b):Object.IsArray(b)?this.each(function(){return this[a]=b[++c%b.length]}):this.each(function(){return this[a]=b})},zipzapmap:function(a,b){var c;c=this.zip(a);c=c.map(b);return this.zap(a,c)},take:function(e){var b,c,i,g,d;i=this.len();d=0;c=Math.min(e|0,i);e<0&&(d=Math.max(0,i+e),c=i);b=a();b.context=this;b.selector=function(){return b.context.take(e)};g=0;for(i=d;d<=c?i<c:i>c;d<=c?i++:i--)b[g++]=this[i];return b},skip:function(e){var b,c,i,g,d;e==null&&(e=0);d=Math.max(0,
e|0);c=this.len();b=a();b.context=this;b.selector=function(){return b.context.skip(e)};g=0;for(i=d;d<=c?i<c:i>c;d<=c?i++:i--)b[g++]=this[i];return b},first:function(a){a==null&&(a=1);return a===1?this[0]:this.take(a)},last:function(a){a==null&&(a=1);return a===1?this[this.len()-1]:this.skip(this.len()-a)},slice:function(e,b){var c,i,g;e==null&&(e=0);b==null&&(b=this.len());g=0;i=this.len();e<0&&(e+=i);b<0&&(b+=i);c=a();c.context=this;c.selector=function(){return c.context.slice(e,b)};for(i=e;e<=b?
i<b:i>b;e<=b?i++:i--)c[g++]=this[i];return c},concat:function(a){var b,c,i;b=this.len()-1;c=-1;for(i=Object.IsFunc(a.len)?a.len():a.length;c<i-1;)this[++b]=a[++c];return this},push:function(a){Array.prototype.push.call(this,a);return this},filter:function(e){var b,c,i,g,d,m;b=a();b.context=this;b.selector=function(){return b.context.filter(e)};switch(Object.Type(e)){case "string":c=function(a){return a.matchesSelector(e)};break;case "regexp":c=function(a){return e.test(a)};break;case "function":c=
e;break;default:throw Error("unsupported type passed to filter: "+Object.Type(e));}g=0;for(d=0,m=this.length;d<m;d++)i=this[d],c.call(i,i)&&(b[g++]=i);return b},test:function(a){return this.map(function(){return a.test(this)})},matches:function(a){return this.zip("matchesSelector").call(a)},querySelectorAll:function(e){return this.filter("*").reduce(function(a,c){return Array.Extend(a,c.querySelectorAll(e))},a())},weave:function(e){var b,c,i,g;g=this.len();i=e.length;c=g-1;b=a();b.context=this;b.selector=
function(){return b.context.weave(e)};for(c=g-=1;g<=0?c<=0:c>=0;g<=0?c++:c--)b[c*2+1]=this[c];for(c=0;0<=i?c<i:c>i;0<=i?c++:c--)b[c*2]=e[c];return b},fold:function(e){var b,c,i,g,d;g=this.len();i=0;b=a();b.context=this;b.selector=function(){return b.context.fold(e)};for(c=0,d=g-1;c<d;c+=2)b[i++]=e.call(this,this[c],this[c+1]);g%2===1&&(b[i++]=e.call(this,this[g-1],void 0));return b},flatten:function(){var e,b,c,i,g,d,m;e=a();e.context=this;e.selector=function(){return e.context.flatten()};m=this.len();
for(i=d=0;0<=m?i<m:i>m;0<=m?i++:i--){b=this[i];c=Object.IsFunc(b.len)?b.len():b.length;for(g=0;0<=c?g<c:g>c;0<=c?g++:g--)e[d++]=b[g]}return e},call:function(){return this.apply(null,arguments)},apply:function(a,b){return this.map(function(){return Object.IsFunc(this)?this.apply(a,b):this})},toString:function(){return a.symbol+"(["+this.map(function(){var a;a=Object.Type(this);return a==="undefined"||a==="null"||a==="window"?a:this.toString().replace(A,"$1")}).join(", ")+"])"},delay:function(a,b){b&&
h.schedule(Function.Bound(b,this),a);return this},log:function(a){var b;b=this.len();a?q(a,this,b+" items"):q(this,b+" items");return this},len:function(){var a;for(a=this.length;this[a]!==void 0;)a++;for(;a>-1&&this[a]===void 0;)a--;return a+1}}});a.plugin(function(){var j,h,f,e,b,c;h=function(a,g){var d;a.parentNode==null&&(d=document.createDocumentFragment(),d.appendChild(a));return a.parentNode.insertBefore(g,a)};j=function(a,g){var d;a.parentNode==null&&(d=document.createDocumentFragment(),d.appendChild(a));
return a.parentNode.insertBefore(g,a.nextSibling)};c=function(i){switch(Object.Type(i)){case "fragment":return i;case "node":return i;case "bling":return i.toFragment();case "string":return a(i).toFragment();case "function":return a(i.toString()).toFragment();default:throw Error("toNode called with invalid argument: "+i+" (type: "+Object.Type(i)+")");}};e=null;b=function(a){return function(){return window.getComputedStyle(this,null).getPropertyValue(a)}};f=function(a){var g,d,b,c,e,f,h;f=[];g="A".charCodeAt(0);
d="Z".charCodeAt(0);b="a".charCodeAt(0);for(e=0,h=a.length;0<=h?e<h:e>h;0<=h?e++:e--)c=a.charCodeAt(e),d>=c&&c>=g&&(c=c-g+b,f.push("-")),f.push(String.fromCharCode(c));return f.join("")};return{name:"Html",$:{HTML:{parse:function(a){var g,d,b,c;c=document.createElement("div");c.innerHTML=a;a=c.childNodes;b=a.length;if(b===1)return c.removeChild(a[0]);g=document.createDocumentFragment();for(d=0;0<=b?d<b:d>b;0<=b?d++:d--)g.appendChild(c.removeChild(a[0]));return g},stringify:function(a){var g,d;switch(Object.Type(a)){case "string":return a;
case "node":return a=a.cloneNode(!0),g=document.createElement("div"),g.appendChild(a),d=g.innerHTML,g.removeChild(a),d;default:return"unknown type: "+Object.Type(a)}},escape:function(i){e||(e=a("<div>&nbsp;</div>").child(0));i=e.zap("data",i).zip("parentNode.innerHTML").first();e.zap("data","");return i}},dataName:function(a){return f(a)}},html:function(a){switch(Object.Type(a)){case "undefined":return this.zip("innerHTML");case "string":return this.zap("innerHTML",a);case "bling":return this.html(a.toFragment());
case "node":return this.each(function(){var g;this.replaceChild(this.childNodes[0],a);for(g=[];this.childNodes.length>1;)g.push(this.removeChild(this.childNodes[1]));return g})}},append:function(a){var g,a=c(a);g=this.zip("appendChild");g.take(1).call(a);g.skip(1).each(function(d){return d(a.cloneNode(!0))});return this},appendTo:function(i){a(i).append(this);return this},prepend:function(a){a!=null&&(a=c(a),this.take(1).each(function(){return h(this.childNodes[0],a)}),this.skip(1).each(function(){return h(this.childNodes[0],
a.cloneNode(!0))}));return this},prependTo:function(i){i!=null&&a(i).prepend(this);return this},before:function(a){a!=null&&(a=c(a),this.take(1).each(function(){return h(this,a)}),this.skip(1).each(function(){return h(this,a.cloneNode(!0))}));return this},after:function(a){a!=null&&(a=c(a),this.take(1).each(function(){return j(this,a)}),this.skip(1).each(function(){return j(this,a.cloneNode(!0))}));return this},wrap:function(a){a=c(a);if(Object.IsFragment(a))throw Error("cannot wrap with a fragment");
return this.map(function(g){var d,b;if(Object.IsFragment(g))a.appendChild(g);else if(Object.IsNode(g))(b=g.parentNode)?(d=document.createElement("dummy"),a.appendChild(b.replaceChild(d,g)),b.replaceChild(a,d)):a.appendChild(g);return g})},unwrap:function(){return this.each(function(){if(this.parentNode&&this.parentNode.parentNode)return this.parentNode.parentNode.replaceChild(this,this.parentNode);else if(this.parentNode)return this.parentNode.removeChild(this)})},replace:function(i){var g,d,i=c(i);
g=a();d=0;this.take(1).each(function(){var a;(a=this.parentNode)!=null&&a.replaceChild(i,this);return g[d++]=i});this.skip(1).each(function(){var a,b;a=i.cloneNode(!0);(b=this.parentNode)!=null&&b.replaceChild(a,this);return g[d++]=a});return g},attr:function(a,g){switch(g){case void 0:return this.zip("getAttribute").call(a,g);case null:return this.zip("removeAttribute").call(a,g);default:return this.zip("setAttribute").call(a,g),this}},addClass:function(a){return this.removeClass(a).each(function(){var g;
g=this.className.split(" ").filter(function(a){return a!==""});g.push(a);return this.className=g.join(" ")})},removeClass:function(a){var g;g=function(d){return d!==a};return this.each(function(){return this.className=this.className.split(" ").filter(g).join(" ")})},toggleClass:function(a){var g;g=function(d){return d!==a};return this.each(function(){var d;d=this.className.split(" ");return d.indexOf(a)>-1?this.className=d.filter(g).join(" "):(d.push(a),this.className=d.join(" "))})},hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},
text:function(a){return a!=null?this.zap("textContent",a):this.zip("textContent")},val:function(a){return a!=null?this.zap("value",a):this.zip("value")},css:function(a,g){var d,c,e,f;if(g!=null||Object.IsObject(a)){f=this.zip("style.setProperty");e=f.len();if(Object.IsObject(a))for(d in a)f.call(d,a[d],"");else if(Object.IsString(g))f.call(a,g,"");else if(Object.IsArray(g)){c=Math.max(g.length,e);for(d=0;0<=c?d<c:d>c;0<=c?d++:d--)f[d%e](a,g[d%c],"")}return this}else return d=this.map(b(a)),c=this.zip("style").zip(a),
c.weave(d).fold(function(a,d){return a||d})},defaultCss:function(i,g){var d,b,c;b=this.selector;c="";if(Object.IsString(i))if(Object.IsString(g))c+=""+b+" { "+i+": "+g+" } ";else throw Error("defaultCss requires a value with a string key");else if(Object.IsObject(i)){c+=""+b+" { ";for(d in i)c+=""+d+": "+i[d]+"; ";c+="} "}a.synth("style").text(c).appendTo("head");return this},empty:function(){return this.html("")},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(a){return a===
null?this.rect().zip("width"):this.css("width",a)},height:function(a){return a===null?this.rect().zip("height"):this.css("height",a)},top:function(a){return a===null?this.rect().zip("top"):this.css("top",a)},left:function(a){return a===null?this.rect().zip("left"):this.css("left",a)},bottom:function(a){return a===null?this.rect().zip("bottom"):this.css("bottom",a)},right:function(a){return a===null?this.rect().zip("right"):this.css("right",a)},position:function(a,g){return a===null?this.rect():g===
null?this.css("left",Number.Px(a)):this.css({top:Number.Px(g),left:Number.Px(a)})},center:function(b){var g,d,c;b==null&&(b="viewport");g=document.body;d=g.scrollTop+g.clientHeight/2;c=g.scrollLeft+g.clientWidth/2;return this.each(function(){var g,e,f;e=a(this);g=e.height().floats().first();f=e.width().floats().first();f=b==="viewport"||b==="horizontal"?c-f/2:NaN;g=b==="viewport"||b==="vertical"?d-g/2:NaN;return e.css({position:"absolute",left:Number.Px(f),top:Number.Px(g)})})},scrollToCenter:function(){document.body.scrollTop=
this.zip("offsetTop")[0]-window.innerHeight/2;return this},child:function(a){return this.zip("childNodes").map(function(){var g;g=a;g<0&&(g+=this.length);return this[g]})},children:function(){return this.map(function(){return a(this.childNodes,this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){var b,g,d;b=a();g=0;for(d=this;d=d.parentNode;)b[g++]=d;return b})},prev:function(){return this.map(function(){var b,g,d;b=a();g=0;for(d=this;d=d.previousSibling;)b[g++]=
d;return b})},next:function(){return this.map(function(){var b,g,d;b=a();g=0;for(d=this;d=d.nextSibling;)b[g++]=d;return b})},remove:function(){return this.each(function(){if(this.parentNode)return this.parentNode.removeChild(this)})},find:function(b){return this.filter("*").map(function(){return a(b,this)}).flatten()},clone:function(a){a==null&&(a=!0);return this.map(function(){return Object.IsNode(this)?this.cloneNode(a):null})},data:function(b,g){b="data-"+f(b);return a(this).attr(b,g)},toFragment:function(){var a,
g;return this.len()>1?(g=document.createDocumentFragment(),a=Function.Bound(g.appendChild,g),this.map(c).map(a),g):c(this[0])}}});a.plugin(function(){return{name:"Maths",$:{range:function(a,h,f){var e,b,c;f==null&&(f=1);b=a;if(f===0||f>0&&a>h||f<0&&a<h)return[];for(c=[];a>h&&b>h||a<h&&b<h;)e=b,b+=f,c.push(e);return c}},floats:function(){return this.map(parseFloat)},ints:function(){return this.map(function(){return parseInt(this,10)})},px:function(a){a==null&&(a=0);return this.ints().map(Function.Px(a))},
min:function(){return this.reduce(function(a){return Math.min(this,a)})},max:function(){return this.reduce(function(a){return Math.max(this,a)})},average:function(){return this.sum()/this.len()},sum:function(){return this.reduce(function(a){return a+this})},squares:function(){return this.map(function(){return this*this})},magnitude:function(){return Math.sqrt(this.floats().squares().sum())},scale:function(a){return this.map(function(){return a*this})},normalize:function(){return this.scale(1/this.magnitude())}}});
a.plugin(function(){var j,h,f,e,b,c,i;j=function(a){return function(d){d==null&&(d={});return Object.IsFunc(d)?this.bind(a,d):this.trigger(a,d)}};e=function(g,d,b,c,e){return a(d).bind(b,e).each(function(){var a;a=this.__alive__||(this.__alive__={});a=a[g]||(a[g]={});return(a[b]||(a[b]={}))[c]=e})};i=function(g,d,b,c){var e;e=a(d);return e.each(function(){var a;a=this.__alive__||(this.__alive__={});a=a[g]||(a[g]={});a=a[b]||(a[b]={});e.unbind(b,a[c]);return delete a[c]})};h=f=0;c=function(){if(!f++)return a(document).trigger("ready").unbind("ready"),
typeof document.removeEventListener==="function"&&document.removeEventListener("DOMContentLoaded",c,!1),typeof window.removeEventListener==="function"?window.removeEventListener("load",c,!1):void 0};h++||(typeof document.addEventListener==="function"&&document.addEventListener("DOMContentLoaded",c,!1),typeof window.addEventListener==="function"&&window.addEventListener("load",c,!1));b={name:"Events",bind:function(a,d){var c,e;c=(a||"").split(s);e=function(a){b=d.apply(this,arguments);b===!1&&Event.Prevent(a);
return b};return this.each(function(){var a,d,g,b;b=[];for(d=0,g=c.length;d<g;d++)a=c[d],b.push(this.addEventListener(a,e,!1));return b})},unbind:function(a,d){var b;b=(a||"").split(s);return this.each(function(){var a,g,c,e;e=[];for(g=0,c=b.length;g<c;g++)a=b[g],e.push(this.removeEventListener(a,d,null));return e})},once:function(a,d){var b,c,e,f,i;b=(a||"").split(s);i=[];for(e=0,f=b.length;e<f;e++)c=b[e],i.push(this.bind(c,function(a){d.call(this,a);return this.removeEventListener(a.type,arguments.callee,
null)}));return i},cycle:function(){var a,d,b,c,e,f,i;a=arguments[0];b=2<=arguments.length?o.call(arguments,1):[];a=(a||"").split(s);e=b.length;d=function(){var a;a=0;return function(d){b[a].call(this,d);return a=++a%e}};for(f=0,i=a.length;f<i;f++)c=a[f],this.bind(c,d());return this},trigger:function(a,d){var b,c,e,f,i;d==null&&(d={});e=(a||"").split(s);d=Object.Extend({bubbles:!0,cancelable:!0},d);for(f=0,i=e.length;f<i;f++){c=e[f];if(c==="click"||c==="mousemove"||c==="mousedown"||c==="mouseup"||
c==="mouseover"||c==="mouseout")b=document.createEvent("MouseEvents"),d=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,button:0,relatedTarget:null},d),b.initMouseEvent(c,d.bubbles,d.cancelable,window,d.detail,d.screenX,d.screenY,d.clientX,d.clientY,d.ctrlKey,d.altKey,d.shiftKey,d.metaKey,d.button,d.relatedTarget);else if(c==="blur"||c==="focus"||c==="reset"||c==="submit"||c==="abort"||c==="change"||c==="load"||c==="unload")b=document.createEvent("UIEvents"),
b.initUIEvent(c,d.bubbles,d.cancelable,window,1);else if(c==="touchstart"||c==="touchmove"||c==="touchend"||c==="touchcancel")b=document.createEvent("TouchEvents"),d=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},d),b.initTouchEvent(c,d.bubbles,d.cancelable,window,d.detail,d.screenX,d.screenY,d.clientX,d.clientY,d.ctrlKey,d.altKey,d.shiftKey,d.metaKey,d.touches,d.targetTouches,
d.changedTouches,d.scale,d.rotation);else if(c==="gesturestart"||c==="gestureend"||c==="gesturecancel")b=document.createEvent("GestureEvents"),d=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,target:null,scale:1,rotation:0},d),b.initGestureEvent(c,d.bubbles,d.cancelable,window,d.detail,d.screenX,d.screenY,d.clientX,d.clientY,d.ctrlKey,d.altKey,d.shiftKey,d.metaKey,d.target,d.scale,d.rotation);else{b=document.createEvent("Events");b.initEvent(c,
d.bubbles,d.cancelable);try{b=Object.Extend(b,d)}catch(h){}}if(b)try{this.each(function(){return this.dispatchEvent(b)})}catch(j){q("dispatchEvent error:",j)}}return this},live:function(b,d){var c,f;f=this.selector;c=this.context;e(f,c,b,d,function(b){return a(f,c).intersect(a(b.target).parents().first().union(a(b.target))).each(function(){b.target=this;return d.call(this,b)})});return this},die:function(b,d){var c,e;e=this.selector;c=this.context;e=i(e,c,b,d);a(c).unbind(b,e);return this},liveCycle:function(){var a,
b,c;a=arguments[0];b=2<=arguments.length?o.call(arguments,1):[];c=0;return this.live(a,function(a){b[c].call(this,a);return c=++c%b.length})},click:function(a){a==null&&(a={});this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");return Object.IsFunc(a)?this.bind("click",a):this.trigger("click",a)},ready:function(a){a==null&&(a={});return Object.IsFunc(a)?f?a.call(this):this.bind("ready",a):this.trigger("ready",a)}};"mousemove,mousedown,mouseup,mouseover,mouseout,blur,focus,load,unload,reset,submit,keyup,keydown,change,abort,cut,copy,paste,selection,drag,drop,orientationchange,touchstart,touchmove,touchend,touchcancel,gesturestart,gestureend,gesturecancel,hashchange".split(",").forEach(function(a){return b[a]=
j(a)});return b});a.plugin(function(){var j,h,f,e,b,c,i;h={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};j=/(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;f=document.createElement("div").style;"WebkitTransform"in f?(e="-webkit-transform",c="-webkit-transition-property",b="-webkit-transition-duration",i="-webkit-transition-timing-function"):"MozTransform"in f?(e="-moz-transform",c="-moz-transition-property",b="-moz-transition-duration",i="-moz-transition-timing-function"):
"OTransform"in f&&(e="-o-transform",c="-o-transition-property",b="-o-transition-duration",i="-o-transition-timing-function");return{name:"Transform",$:{duration:function(a){var b;b=h[a];return b!=null?b:parseFloat(a)}},transform:function(g,d,f,h){var x,n,k,l,p,r;Object.IsFunc(d)?(h=d,f=d=null):Object.IsFunc(f)&&(h=f,f=null);d==null&&(d="normal");f||(f="ease");x=a.duration(d)+"ms";p=[];l=0;r="";d={};for(n in g)j.test(n)?(k=g[n],k.join?k=a(k).px().join(", "):k.toString&&(k=k.toString()),r+=" "+n+"("+
k+")"):d[n]=g[n];for(n in d)p[l++]=n;r&&(p[l++]=e);d[c]=p.join(", ");d[b]=p.map(function(){return x}).join(", ");d[i]=p.map(function(){return f}).join(", ");r&&(d[e]=r);this.css(d);return this.delay(x,h)},hide:function(a){return this.each(function(){if(this.style){this._display="";if(this.style.display===!1)this._display=this.syle.display;return this.style.display="none"}}).trigger("hide").delay(50,a)},show:function(a){return this.each(function(){if(this.style)return this.style.display=this._display,
delete this._display}).trigger("show").delay(50,a)},toggle:function(b){return this.weave(this.css("display")).fold(function(b,c){b==="none"?(c.style.display=c._display||"",delete c._display,a(c).trigger("show")):(c._display=b,c.style.display="none",a(c).trigger("hide"));return c}).delay(50,b)},fadeIn:function(a,b){return this.css("opacity","0.0").show(function(){return this.transform({opacity:"1.0",translate3d:[0,0,0]},a,b)})},fadeOut:function(a,b,c,e){c==null&&(c=0);e==null&&(e=0);return this.transform({opacity:"0.0",
translate3d:[c,e,0]},a,function(){return this.hide(b)})},fadeLeft:function(a,b){return this.fadeOut(a,b,"-"+this.width().first(),0)},fadeRight:function(a,b){return this.fadeOut(a,b,this.width().first(),0)},fadeUp:function(a,b){return this.fadeOut(a,b,0,"-"+this.height().first())},fadeDown:function(a,b){return this.fadeOut(a,b,0,this.height().first())}}});a.plugin(function(){var j;j=function(a){var f,e,b;b=[];e=0;a=JSON.parse(JSON.stringify(a));for(f in a)b[e++]=""+f+"="+escape(a[f]);return b.join("&")};
return{name:"Http",$:{http:function(h,f){var e;f==null&&(f={});e=new XMLHttpRequest;Object.IsFunc(f)&&(f={success:Function.Bound(f,e)});f=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:!0,timeout:0,withCredentials:!1,followRedirects:!1,asBlob:!1},f);f.state=Function.Bound(f.state,e);f.success=Function.Bound(f.success,e);f.error=Function.Bound(f.error,e);if(f.data&&f.method==="GET")h+="?"+j(f.data);else if(f.data&&f.method==="POST")f.data=
j(f.data);e.open(f.method,h,f.async);e.withCredentials=f.withCredentials;e.asBlob=f.asBlob;e.timeout=f.timeout;e.followRedirects=f.followRedirects;e.onreadystatechange=function(){f.state&&f.state();if(e.readyState===4)return e.status===200?f.success(e.responseText):f.error(e.status,e.statusText)};e.send(f.data);return a([e])},post:function(h,f){f==null&&(f={});Object.IsFunc(f)&&(f={success:f});f.method="POST";return a.http(h,f)},get:function(h,f){f==null&&(f={});Object.IsFunc(f)&&(f={success:f});
f.method="GET";return a.http(h,f)}}}});a.plugin(function(){var j,h,f,e,b,c;f=function(a,b,c,e,f){var h,j;h=1;if(f===null||f===-1)f=a.length;for(j=e;e<=f?j<f:j>f;e<=f?j++:j--)if(a[j]===c?h+=1:a[j]===b&&(h-=1),h===0)return j;return-1};c=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;j=/%[\(\/]/;h=function(a){var b,d,e,h,x,n,k,a=a.split(j);x=a.length;k=[a[0]];for(d=e=1;1<=x?d<x:d>x;1<=x?d++:d--){b=f(a[d],")","(",0,-1);if(b===-1)return"Template syntax error: unmatched '%(' starting at: "+
a[d].substring(0,15);h=a[d].substring(0,b);n=a[d].substring(b);b=c.exec(n);if(b===null)return"Template syntax error: invalid type specifier starting at '"+n+"'";n=b[4];k[e++]=h;k[e++]=b[1]|0;k[e++]=b[2]|0;k[e++]=b[3];k[e++]=n}return k};h.cache={};e=function(a,b){var c,e,f,j,n,k,l,p,r,t,o,u;c=h.cache[a];c===null&&(c=h.cache[a]=h(a));k=[c[0]];j=1;e=c.length;for(f=1,o=e-5;f<=o;f+=5){u=c.slice(f,f+4+1||9E9);n=u[0];l=u[1];e=u[2];r=u[3];p=u[4];t=b[n];t==null&&(t="missing value: "+n);switch(r){case "d":k[j++]=
""+parseInt(t,10);break;case "f":k[j++]=parseFloat(t).toFixed(e);break;case "s":k[j++]=""+t;break;default:k[j++]=""+t}l>0&&(k[j]=String.PadLeft(k[j],l));k[j++]=p}return k.join("")};b=function(b){var c,d,e,f,h,j,k,l,p,r,t,o,u,v,w,q,s,y,z;w=null;s=u=k=d=z=y="";e={};v=0;q=a([]);q.selector=b;t=function(){var b;b=a.HTML.parse(y);w?w.appendChild(b):q.push(b);y="";return 0};l=function(){var a,b;b=document.createElement(s);b.id=u||null;b.className=k||null;for(a in e)b.setAttribute(a,e[a]);w?w.appendChild(b):
q.push(b);w=b;s=u=k=d=z=y="";e={};return 0};p=function(){l();w=null;return 0};r=function(){l();if(w)w=w.parentNode;return 0};h=function(){k.length>0&&(k+=" ");return 2};f=function(){return 3};o=function(){e[d]=z;d=z="";return 0};j=function(){return 1};c=function(a){y+=a;return null};h=[{'"':function(){return 5},"'":function(){return 6},"#":j,".":h,"[":f,"+":r," ":l,",":p,def:function(a){s+=a;return null}},{".":h,"[":f,"+":r," ":l,",":p,def:function(a){u+=a;return null}},{"#":j,".":h,"[":f,"+":r," ":l,
",":p,def:function(a){k+=a;return null}},{"=":function(){return 4},"]":o,def:function(a){d+=a;return null}},{"]":o,def:function(a){z+=a;return null}},{'"':t,def:c},{"'":t,def:c}];for(f=0;c=b[f++];)j=v,v=h[v],v=c in v?v[c](c):v.def(c),v===null&&(v=j);s.length>0&&l();y.length>0&&t();return q};return{name:"Template",$:{render:e,synth:b},template:function(b){this.render=function(c){return e(this.map(a.HTML.stringify).join(""),Object.Extend(b,c))};return this.remove()},render:function(b){return e(this.map(a.HTML.stringify).join(""),
b)},synth:function(a){return b(a).appendTo(this)}}});a.plugin(function(){var j,h;h={};j={};return{name:"Pub/Sub",$:{publish:function(f,e){var b,c,i,g,d;e==null&&(e=[]);a.log("published: "+f,e);!f in j&&(j[f]=[]);j[f].push(e);if(f in h){g=h[f];d=[];for(c=0,i=g.length;c<i;c++)b=g[c],d.push(b.apply(window,e));return d}},subscribe:function(f,e){var b,c,i,g;!f in h&&(h[f]=[]);if(f in j){g=j[f];for(c=0,i=g.length;c<i;c++)b=g[c],a.log("replayed: "+f,b),e.apply(window,b)}return h[f].push(e)}}}});a.plugin(function(){var j,
h;j=function(a,e){return Object.Extend(document.createElement(a),e)};h=function(f,e){var b;b=j(f,Object.Extend(e,{onload:function(){if(provides!==null)return a.publish(provides)}}));a("head").delay(10,function(){return depends!==null?a.subscribe(depends,B(function(){return this.append(b)},this)):this.append(b)});b=a(b);return Object.Extend(b,{depends:function(){return b},provides:function(){return b}})};return{name:"LazyLoader",$:{script:function(a){return h("script",{src:a})},style:function(a){return h("style",
{href:a})}}}});return a}(l))}).call(this);
