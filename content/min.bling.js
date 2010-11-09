Function.prototype.inherit=function(d){this.prototype=new d;return this.prototype.constructor=this};function isType(d,f){return!d?f===d:typeof f==="string"?d.__proto__.constructor.name==f:d.__proto__.constructor===f}function isSubtype(d,f){return d==null?d==f:d.__proto__==null?false:typeof f==="string"?d.__proto__.constructor.name==f:d.__proto__.constructor==f?true:isSubtype(d.__proto__,f)}function isString(d){return typeof d=="string"||isSubtype(d,String)}isNumber=isFinite;
function isFunc(d){return typeof d=="function"||isType(d,Function)}function isNode(d){return d?d.nodeType>0:false}function isFragment(d){return d?d.nodeType==11:false}function isArray(d){return d?Function.ToString(d)=="[object Array]"||isSubtype(d,Array):false}function isObject(d){return typeof d=="object"}function hasValue(d){return d!=null}Bling.extend=function(d,f,b){for(var c in f)if(b&&d[c]!=undefined)for(var a in b)d[c][a]=f[c][a];else d[c]=f[c];return d};
Function.prototype.bound=function(d,f){function b(){return c.apply(d,f?f:arguments)}var c=this;b.toString=function(){return"bound-method of "+d+"."+c.name+"(...) { [code] }"};return b};var OtoS=Object.prototype.toString;Array.Slice=function(d,f,b){var c=[],a=0,e=d.length;b=b==undefined?e:b<0?e+b:b;for(f=f==undefined?0:f<0?e+f:f;f<b;)c[a++]=d[f++];return c};Number.Px=function(d,f){return parseInt(d)+(f|0)+"px"};
Bling.extend(Function,{Empty:function(){},NotNull:function(d){return d!=null},NotUndefined:function(d){return d!=undefined},IndexFound:function(d){return d>-1},ReduceAnd:function(d){return d&&this},UpperLimit:function(d){return function(f){return Math.min(d,f)}},LowerLimit:function(d){return function(f){return Math.max(d,f)}},ToString:function(d){return OtoS.apply(d)},Px:function(d){return function(){return Number.Px(this,d)}}});
Bling.extend(String,{HtmlEscape:function(d){return d.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\t/g,"&nbsp;&nbsp;")},PadLeft:function(d,f,b){for(b=b||" ";d.length<f;)d=b+d;return d},Splice:function(){var d=arguments[0],f=arguments[1],b=arguments[2],c=Array.Slice(arguments,3).join("");return d.substring(0,f)+c+d.substring(b)}});
(function(){function d(j){var n=0,o=j.length,l=[],m=-1,k=-1,p=null;if(!isString(j))if(isFunc(j.toString)){j=j.toString();o=j.length}else throw TypeError("invalid string argument to extract_quoted");for(;n<o;){m=j;k=n;p=m.indexOf('"',k);k=m.indexOf("'",k);if(p==-1)p=m.length;if(k==-1)k=m.length;p=p==k?[null,-1]:p<k?['"',p]:["'",k];m=p[1];if(m==-1){l.push(j.substring(n));break}l.push(j.substring(n,m));n=j;k=p[0];for(var q=n.indexOf(k,m+1);n.charAt(q-1)=="\\"&&q<n.length&&q>0;)q=n.indexOf(k,q+1);k=q;
if(k==-1)throw Error("unmatched "+p[0]+" at "+m);l.push(j.substring(m,k+1));n=k+1}return l}function f(j){for(var n=[],o=0,l=0,m=j.length,k=null,p=null;o<m;){k=p=j.substring(o);l=k.match(a);k=k.match(e);k=l==k?[-1,null]:l==null&&k!=null?[k.index,k[0]]:l!=null&&k==null?[l.index,l[0]]:k.index<l.index?[k.index,k[0]]:[l.index,l[0]];l=k[0];if(l>-1){n.push(p.substring(0,l));n.push(k[1]);o+=l+k[1].length}else{n.push(p);break}}return n}var b=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g,
c=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b/g,a=/\/\/.*?\n/,e=/\/\*(?:.|\n)*?\*\//,g=/\d+\.*\d*/g,h=false;Function.PrettyPrint=function(j){if(isFunc(j))j=j.toString();if(!isString(j))throw TypeError("prettyPrint requires a function or string to format");if(!h){$("head").append("<style> .pretty .opr { color: #880; } .pretty .str { color: #008; } .pretty .com { color: #080; } .pretty .kwd { color: #088; } .pretty .num { color: #808; }</style>");
h=true}return"<pre class='pretty'>"+$(f(j)).fold(function(n,o){return $(d(n)).fold(function(l,m){return l.replace(b,"<span class='opr'>$&</span>").replace(g,"<span class='num'>$&</span>").replace(c,"<span class='kwd'>$&</span>").replace(/\t/g,"&nbsp;&nbsp;")+(m?"<span class='str'>"+m+"</span>":"")}).join("")+(o?"<span class='com'>"+o+"</span>":"")}).join("")+"</pre>"}})();
function Bling(d,f){if(isBling(d))return d;f=f||document;if(d===undefined)return Bling.__init__(d,f,[]);if(typeof d==="string"){d=d.trimLeft();if(d[0]=="<")return Bling.__init__(d,f,[Bling.HTML.parse(d)]);if(isBling(f))return f.reduce(function(c,a){c.union(a.querySelectorAll(d))},Bling.__init__(d,f,[]));if(f.querySelectorAll!=undefined)try{return Bling.__init__(d,f,f.querySelectorAll(d))}catch(b){console.log("err",b,d,f);return null}throw Error("invalid parameters: "+d+", "+f);}if(typeof d==="number")return Bling.__init__(d,
f,Array(d));if(d===window||isNode(d))return Bling.__init__(d,f,[d]);if(d.length!=undefined)return Bling.__init__(d,f,d);return Bling.__init__(d,f,[d])}Bling.inherit(Array);function isBling(d){return isType(d,Bling)}Bling.__init__=function(d,f,b){b.__proto__=Bling.prototype;b.selector=d;b.context=f;return b};
Bling.addOps=function(){for(var d=0,f=arguments.length;d<f;d++){var b=arguments[d];if(isFunc(b)){if(b.name==null)throw Error("cannot extend with an anonymous method (must have a name)");Bling.prototype[b.name]=b}else if(isObject(b))Bling.extend(Bling.prototype,b);else throw Error("can only extend by an object or function, not:"+typeof b);}};Bling.module=function(d,f){var b=f(),c=arguments.callee;c.order.push(d);c[d]=b;Bling.addOps(b)};Bling.module.order=[];
Bling.module("Core",function(){function d(b){if(isObject(b)&&isNumber(b))return Number(b);return b}var f=new function(){this.queue=[];this.next=function(){this.queue.length>0&&this.queue.shift()()}.bound(this);this.schedule=function(b,c){if(isFunc(b)){var a=this.queue.length;b.order=c+(new Date).getTime();if(a==0||b.order>this.queue[a-1].order)this.queue[a]=b;else for(var e=0;e<a;e++)this.queue[e].order>b.order&&this.queue.splice(e,0,b);setTimeout(this.next,c)}}};return{each:function(b){for(var c=
-1,a=this.len(),e=null;++c<a;){e=this[c];b.call(e,e)}return this},map:function(b){var c=this.len(),a=Bling(c),e=0,g=null;a.context=this;for(a.selector=b;e<c;e++){g=this[e];try{a[e]=b.call(g,g)}catch(h){if(isType(h,TypeError))a[e]=b(g);else throw h;}}return a},reduce:function(b,c){if(!b)return this;var a=c,e=this;if(c==null){a=this[0];e=this.skip(1)}e.each(function(){a=b.call(this,a,this)});return a},filter:function(b){var c=0,a=-1,e=this.length,g=Bling(e),h=null;g.context=this;for(g.selector=b;c<
e;c++)if(h=this[c])if(isFunc(b)&&b.call(h,h)||isString(b)&&h.webkitMatchesSelector&&h.webkitMatchesSelector(b))g[++a]=h;return g},matches:function(b){return this.map(function(){if(this.webkitMatchesSelector)return this.webkitMatchesSelector(b);return false})},union:function(b){var c=Bling(),a=0,e=0,g=null;c.context=this.context;c.selector=this.selector;for(this.each(function(){c[a++]=this});g=b[e++];)c.contains(g)||(c[a++]=g);return c},intersect:function(b){var c=Bling(),a=0,e=0,g=this.length,h=b.length;
c.context=this.context;c.selector=this.selector;if(isBling(b))for(;a<g;a++){if(b.contains(this[a]))c[c.length]=this[a]}else for(a=0;a<g;a++)for(;e<h;e++)if(this[a]==b[e])c[c.length]=this[a];return c},distinct:function(){return this.union(this)},contains:function(b){return this.count(b)>0},count:function(b){if(b==undefined)return this.len();b=d(b);if(isObject(b)&&isNumber(b))b=Number(b);var c=0;this.each(function(){var a=this;if(isObject(a)&&isNumber(a))a=Number(a);a==b&&c++});return c},zip:function(){function b(l){var m;
return function(){m=this[l];return isFunc(m)?m.bound(this):m}}function c(l){var m=l.indexOf(".");return m>-1?this.zip(l.substr(0,m)).zip(l.substr(m+1)):this.map(b(l))}switch(arguments.length){case 0:return this;case 1:return c.call(this,arguments[0]);default:var a={},e=Bling(),g=arguments.length,h=this.length,j=0,n=0,o=null;for(j=0;j<g;j++)a[j]=c.call(this,arguments[j]);for(j=0;j<h;j++){g={};for(o in a)g[o]=a[o].shift();e[n++]=g}return e}},zap:function(b,c){if(!b)return this;var a=b.indexOf(".");
return a>-1?this.zip(b.substr(0,a)).zap(b.substr(a+1),c):isArray(c)?this.each(function(e){e[b]=c[++a]}):this.each(function(){this[b]=c})},take:function(b){b=Math.min(b|0,this.len());var c=Bling(b),a=-1;c.context=this.context;for(c.selector=this.selector;++a<b;)c[a]=this[a];return c},skip:function(b){b=Math.min(this.len(),Math.max(0,b|0));var c=Bling(b);i=0;nn=this.len()-b;c.context=this.context;for(c.selector=this.selector;i<nn;i++)c[i]=this[i+b];return c},last:function(b){return b?this.skip(this.len()-
b):this[this.length-1]},first:function(b){return b?this.take(b):this[0]},join:function(b){if(this.length==0)return"";return this.reduce(function(c){return c+b+this})},slice:function(b,c){var a=Bling(Array.Slice(this,b,c));a.context=this.context;a.selector=this.selector;return a},concat:function(b){for(var c=this.len()-1,a=-1,e=b.length;a<e;)this[++c]=b[++a];return this},weave:function(b){var c=b.length,a=this.length,e=Bling(2*Math.max(a,c));i=a-1;e.context=this.context;for(e.selector=this.selector;i>=
0;i--)e[i*2+1]=this[i];for(;++i<c;)e[i*2]=b[i];return e},fold:function(b){var c=this.len(),a=0,e=Bling(Math.ceil(c/2)),g=0;e.context=this.context;e.selector=this.selector;for(g=0;g<c-1;g+=2)e[a++]=b.call(this,this[g],this[g+1]);if(c%2==1)e[a++]=b.call(this,this[c-1],undefined);return e},flatten:function(){var b=Bling(),c=this.len(),a=null,e=0,g=0,h=0,j=0;b.context=this.context;for(b.selector=this.selector;g<c;g++){a=this[g];h=0;for(e=a.length;h<e;)b[j++]=a[h++]}return b},call:function(){return this.apply(null,
arguments)},apply:function(b,c){return this.map(function(){if(isFunc(this))return this.apply(b,c);return this})},toString:function(){return Bling.symbol+"(["+this.map(function(){return this==undefined||this==window?"undefined":this==null?"null":this.toString().replace(/\[object (\w+)\]/,"$1")}).join(", ")+"])"},future:function(b,c){c&&f.schedule(c.bound(this),b);return this},log:function(b){b?console.log(b,this,this.length+" items"):console.log(this,this.length+" items");return this},len:function(){for(var b=
this.length;b>-1&&this[--b]==undefined;);return b+1}}});
Bling.module("Html",function(){function d(a,e){a&&e&&a.parentNode.insertBefore(e,a)}function f(a){a=isNode(a)?a:isBling(a)?a.toFragment():isString(a)?Bling(a).toFragment():isFunc(a.toString)?Bling(a.toString()).toFragment():undefined;Bling.nextguid=Bling.nextguid||1;if(a.guid==null)a.guid=Bling.nextguid++;return a}function b(a){for(var e=a.cloneNode(),g=0;g<a.childNodes.length;g++)e.appendChild(b(a.childNodes[g])).parentNode=e;return e}var c=null;Bling.HTML={parse:function(a){var e=document.createElement("div");
e.innerHTML=a;a=document.createDocumentFragment();for(var g=0,h=e.childNodes.length;g<h;g++)a.appendChild(e.removeChild(e.childNodes[0]));return h==1?a.removeChild(a.childNodes[0]):a},stringify:function(a){a=b(a);var e=document.createElement("div");e.appendChild(a);var g=e.innerHTML;e.removeChild(a);a.parentNode=null;return g},escape:function(a){c=c||Bling("<div>&nbsp;</div>").child(0);a=c.zap("data",a).zip("parentNode.innerHTML").first();c.zap("data","");return a}};Bling.Color={fromCss:function(a){a=
a||this;if(isString(a)){var e=document.createElement("div");e.style.display="none";e.style.color=a;$(document.body).append(e);a=window.getComputedStyle(e).getPropertyValue("color");$(e).remove();if(a){a=a.slice(a.indexOf("(")+1,a.indexOf(")")).split(", ");if(a.length==3)a[3]=1;return Bling(a).floats()}}},toCss:function(a){function e(g){g=g.map(Function.UpperLimit(255)).map(Function.LowerLimit(0));g[3]=Math.min(1,g[3]);return"rgba("+g.join(", ")+")"}a=a||this;return isBling(a[0])?a.map(e):e(a)},invert:function(a){var e=
Bling(4);e[0]=255-a[0];e[1]=255-a[1];e[2]=255-a[2];e[3]=a[3];return e}};return{html:function(a){return a==undefined?this.zip("innerHTML"):isString(a)?this.zap("innerHTML",a):isBling(a)?this.html(a.toFragment()):isNode(a)?this.each(function(){for(this.replaceChild(this.childNodes[0],a);this.childNodes.length>1;)this.removeChild(this.childNodes[1])}):undefined},append:function(a){if(a==null)return this;a=f(a);var e=this.zip("appendChild");e.take(1).call(a);e.skip(1).each(function(){this(b(a))});return this},
appendTo:function(a){if(a==null)return this;Bling(a).append(this);return this},prepend:function(a){if(a==null)return this;a=f(a);this.take(1).each(function(){d(this.childNodes[0],a)});this.skip(1).each(function(){d(this.childNodes[0],b(a))});return this},prependTo:function(a){if(a==null)return this;Bling(a).prepend(this);return this},before:function(a){if(a==null)return this;a=f(a);this.take(1).each(function(){d(this,a)});this.skip(1).each(function(){d(this,b(a))});return this},after:function(a){if(a==
null)return this;a=f(a);this.take(1).each(function(){this.parentNode.insertBefore(a,this.nextSibling)});this.skip(1).each(function(){this.parentNode.insertBefore(b(a),this.nextSibling)});return this},wrap:function(a){a=f(a);if(isFragment(a))throw Error("cannot wrap something with a fragment");return this.map(function(e){if(isFragment(e))a.appendChild(e);else if(isNode(e)){var g=e.parentNode;if(g){var h=document.createElement("dummy");a.appendChild(g.replaceChild(h,e));g.replaceChild(a,h)}else a.appendChild(e)}return e})},
unwrap:function(){return this.each(function(){this.parentNode&&this.parentNode.parentNode&&this.parentNode.parentNode.replaceChild(this,this.parentNode)})},replace:function(a){a=f(a);var e=Bling(),g=-1;this.take(1).each(function(){if(this.parentNode){this.parentNode.replaceChild(a,this);e[++g]=a}});this.skip(1).each(function(){if(this.parentNode){var h=b(a);this.parentNode.replaceChild(h,this);e[++g]=h}});return e},attr:function(a,e){var g=this.zip(e?"setAttribute":"getAttribute").call(a,e);return e?
this:g},addClass:function(a){return this.removeClass(a).each(function(){var e=this.className.split(" ").filter(function(g){return g&&g!=""});e.push(a);this.className=e.join(" ")})},removeClass:function(a){var e=function(g){return g!=a};return this.each(function(){this.className=this.className.split(" ").filter(e).join(" ")})},toggleClass:function(a){function e(g){return g!=a}return this.each(function(g){var h=g.className.split(" ");g.className=h.indexOf(a)>-1?h.filter(e).join(" "):h.push(a).join(" ")})},
hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},text:function(a){return a?this.zap("innerText",a):this.zip("innerText")},val:function(a){return a?this.zap("value",a):this.zip("value")},css:function(a,e){if(hasValue(e)||isObject(a)){var g=this.zip("style.setProperty");if(isString(a))g.call(a,e);else for(var h in a)g.call(h,a[h]);return this}g=this.map(window.getComputedStyle).zip("getPropertyValue").call(a);return this.zip("style").zip(a).weave(g).fold(function(j,
n){return j?j:n})},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(){return this.rect().zip("width")},height:function(a){return a==null?this.rect().zip("height"):this.css("height",a)},top:function(a){return a==null?this.rect().zip("top"):this.css("top",a)},left:function(a){return a==null?this.rect().zip("left"):this.css("left",a)},position:function(a,e){return a==null?this.rect():e==null?this.css("left",Number.Px(a)):this.css({top:Number.Px(e),left:Number.Px(a)})},
center:function(a){a=a||"viewport";var e=document.body.clientHeight/2,g=document.body.clientWidth/2;return this.each(function(){var h=Bling(this),j=h.height().floats().first(),n=h.width().floats().first();n=a=="viewport"||a=="horizontal"?document.body.scrollLeft+g-n/2:NaN;y=a=="viewport"||a=="vertical"?document.body.scrollTop+e-j/2:NaN;h.css({position:"absolute",left:isNumber(n)?n+"px":undefined,top:isNumber(y)?y+"px":undefined})})},trueColor:function(a,e){function e(g){g[0]+=(this[0]-g[0])*this[3];
g[1]+=(this[1]-g[1])*this[3];g[2]+=(this[2]-g[2])*this[3];g[3]=Math.min(1,g[3]+this[3]);return g}a=a||"background-color";return this.parents().map(function(){return this.map(window.getComputedStyle).filter(hasValue).zip("getPropertyValue").call(a).filter(isString).map(Bling.Color.fromCss).reverse().reduce(e,Bling([0,0,0,0])).map(Bling.Color.toCss)})},child:function(a){return this.map(function(){return this.childNodes[a]})},children:function(){return this.map(function(){return Bling(this.childNodes,
this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){for(var a=Bling(),e=-1,g=this;g=g.parentNode;)a[++e]=g;return a})},prev:function(){return this.map(function(){for(var a=Bling(),e=-1,g=this;g=g.previousSibling;)a[++e]=g;return a})},next:function(){return this.map(function(){for(var a=Bling(),e=-1,g=this;g=g.previousSibling;)a[++e]=g;return a})},remove:function(){return this.each(function(){this.parentNode&&this.parentNode.removeChild(this)})},
find:function(a){return this.filter("*").map(function(){return Bling(a,this)}).flatten()},clone:function(){return this.map(b)},toFragment:function(){if(this.length==1)return f(this[0]);var a=document.createDocumentFragment();this.map(f).map(a.appendChild.bound(a));return a}}});
Bling.module("Math",function(){return{floats:function(){return this.map(function(){if(isBling(this))return this.floats();return parseFloat(this)})},ints:function(){return this.map(function(){if(isBling(this))return this.ints();return parseInt(this)})},px:function(d){d=d||0;return this.ints().map(Function.Px(d))},min:function(){return this.reduce(function(d){if(isBling(this))return this.min();return Math.min(this,d)})},max:function(){return this.reduce(function(d){if(isBling(this))return this.max();
return Math.max(this,d)})},average:function(){return this.sum()/this.length},sum:function(){return this.reduce(function(d){if(isBling(this))return d+this.sum();return d+this})},squares:function(){return this.map(function(){if(isBling(this))return this.squares();return this*this})},magnitude:function(){var d=this.map(function(){if(isBling(this))return this.magnitude();return parseFloat(this)});return Math.sqrt(d.squares().sum())},scale:function(d){return this.map(function(){if(isBling(this))return this.scale(d);
return d*this})},normalize:function(){return this.scale(1/this.magnitude())}}});
Bling.module("Event",function(){function d(b){return function(c){return isFunc(c)?this.bind(b,c):this.trigger(b,c?c:{})}}Bling.ready=function(b){return Bling(document).ready(b)};setTimeout(function(){Bling.prototype.trigger!=null&&document.readyState=="complete"?Bling(document).trigger("ready"):setTimeout(arguments.callee,10)},0);var f=/, */;return{bind:function(b,c){var a=0;b=(b||"").split(f);var e=b.length;return this.each(function(){for(;a<e;a++)this.addEventListener(b[a],c)})},unbind:function(b,
c){var a=0;b=(b||"").split(f);var e=b.length;return this.each(function(){for(;a<e;a++)this.removeEventListener(b[a],c)})},once:function(b,c){var a=0;b=(b||"").split(f);for(var e=b.length;a<e;a++)this.bind(b[a],function(g){c.call(this,g);this.unbind(g.type,arguments.callee)})},cycle:function(b){function c(){var j=0;return function(n){e[j].call(this,n);j=++j%h}}var a=0,e=Array.Slice(arguments,1,arguments.length);b=(b||"").split(f);for(var g=b.length,h=e.length;a<g;)this.bind(b[a++],c());return this},
trigger:function(b,c){var a=undefined,e=0;b=(b||"").split(f);var g=b.length,h=null;for(c=Bling.extend({bubbles:true,cancelable:true},c);e<g;e++){h=b[e];switch(h){case "click":case "mousemove":case "mousedown":case "mouseup":case "mouseover":case "mouseout":a=document.createEvent("MouseEvents");c=Bling.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},c);a.initMouseEvent(h,c.bubbles,c.cancelable,window,c.detail,
c.screenX,c.screenY,c.clientX,c.clientY,c.ctrlKey,c.altKey,c.shiftKey,c.metaKey,c.button,c.relatedTarget);break;case "blur":case "focus":case "reset":case "submit":case "abort":case "change":case "load":case "unload":a=document.createEvent("UIEvents");a.initUIEvent(h,c.bubbles,c.cancelable,window,1);break;case "touchstart":case "touchmove":case "touchend":case "touchcancel":a=document.createEvent("TouchEvents");c=Bling.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,
shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},c);a.initTouchEvent(h,c.bubbles,c.cancelable,window,c.detail,c.screenX,c.screenY,c.clientX,c.clientY,c.ctrlKey,c.altKey,c.shiftKey,c.metaKey,c.touches,c.targetTouches,c.changedTouches,c.scale,c.rotation);break;case "gesturestart":case "gestureend":case "gesturecancel":a=document.createEvent("GestureEvents");c=Bling.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,
metaKey:false,target:null,scale:1,rotation:0},c);a.initGestureEvent(h,c.bubbles,c.cancelable,window,c.detail,c.screenX,c.screenY,c.clientX,c.clientY,c.ctrlKey,c.altKey,c.shiftKey,c.metaKey,c.target,c.scale,c.rotation);break;default:a=document.createEvent("Events");a.initEvent(h,c.bubbles,c.cancelable)}a&&this.each(function(){this.dispatchEvent(a);a.result=a.returnValue=undefined})}return this},live:function(b,c){var a=this.selector,e=this.context;Bling(e).bind(b,_handler);e=e.__livers__=e.__livers__||
{};e[a]=e[a]||{};e[a][b]=e[a][b]||[];e[a][b].push(c)},die:function(b,c){var a=this.selector,e=this.context,g=Bling(e);h=e.__livers__;if(h==null)return this;var h=e.__livers__[a][b];a=0;for(e=h.length;a<e;a++)if(c==undefined||c==h[a]){g.unbind(b,c);h.splice(a,1);e--;a--}},liveCycle:function(b){var c=0,a=Array.Slice(arguments,1,arguments.length);return this.live(b,function(e){a[c].call(this,e);c=++c%a.length})},click:function(b){this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");
return isFunc(b)?this.bind("click",b):this.trigger("click",b?b:{})},mousemove:d("mousemove"),mousedown:d("mousedown"),mouseup:d("mouseup"),mouseover:d("mouseover"),mouseout:d("mouseout"),blur:d("blur"),focus:d("focus"),load:d("load"),ready:d("ready"),unload:d("unload"),reset:d("reset"),submit:d("submit"),change:d("change"),abort:d("abort"),cut:d("cut"),copy:d("copy"),paste:d("paste"),selection:d("selection"),drag:d("drag"),drop:d("drop"),orientationchange:d("orientationchange"),touchstart:d("touchstart"),
touchmove:d("touchmove"),touchend:d("touchend"),touchcancel:d("touchcancel"),gesturestart:d("gesturestart"),gestureend:d("gestureend"),gesturecancel:d("gesturecancel")}});
Bling.module("Transform",function(){Bling.duration=function(d){var f={slow:700,medium:500,normal:300,fast:100,instant:0,now:0}[d];return f?f:parseFloat(d)};return{transform:function(d,f,b){if(typeof f=="function"){b=f;f=undefined}f=f||"normal";var c=Bling.duration(f);f=[];var a=0,e="",g={},h;for(h in d)if(/(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/.test(h)){var j=d[h];if(j.join)j=j.join(", ");else if(j.toString)j=j.toString();
e+=" "+h+"("+j+")"}else g[h]=d[h];for(h in g)f[a++]=h;if(e)f[a++]="-webkit-transfrom";this.css("-webkit-transition-property",f.join(", "));this.css("-webkit-transition-duration",f.map(function(){return c+"ms"}).join(", "));for(h in g)this.css(h,g[h]);e&&this.css("-webkit-transform",e);return this.future(c,b)},hide:function(d){return this.each(function(){if(this.style){this._display=this.style.display=="none"?undefined:this.style.display;this.style.display="none"}}).future(50,d)},show:function(d){return this.each(function(){if(this.style){this.style.display=
this._display?this._display:"block";this._display=undefined}}).future(50,d)},toggle:function(d){this.weave(this.css("display")).fold(function(f,b){if(f=="none"){b.style.display=b._old_display?b._old_display:"block";b._old_display=undefined}else{b._old_display=f;b.style.display="none"}return b}).future(50,d)},fadeIn:function(d,f){return this.css("opacity","0.0").show(function(){this.transform({opacity:"1.0",translate3d:[0,0,0]},d,f)})},fadeOut:function(d,f,b,c){b=b||0;c=c||0;return this.each(function(a){Bling(a).transform({opacity:"0.0",
translate3d:[b,c,0]},d,function(){this.hide()})}).future(Bling.duration(d),f)},fadeLeft:function(d,f){return this.fadeOut(d,f,"-"+this.width().first(),0)},fadeRight:function(d,f){return this.fadeOut(d,f,this.width().first(),0)},fadeUp:function(d,f){return this.fadeOut(d,f,0,"-"+this.height().first())},fadeDown:function(d,f){return this.fadeOut(d,f,0,this.height().first())}}});
Bling.module("Http",function(){function d(f){var b=[],c=0;f=JSON.parse(JSON.stringify(f));for(var a in f)b[c++]=a+"="+escape(f[a]);return b.join("&")}Bling.extend(Bling,{http:function(f,b){var c=new XMLHttpRequest;if(isFunc(b))b={success:b.bound(c)};b=Bling.extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:true,withCredentials:false},b);b.state=b.state.bound(c);b.success=b.success.bound(c);b.error=b.error.bound(c);if(b.data&&b.method=="GET")f+="?"+
d(b.data);else if(b.data&&b.method=="POST")b.data=d(b.data);c.open(b.method,f,b.async);c.withCredentials=b.withCredentials;c.onreadystatechange=function(){b.state&&b.state();if(c.readyState==4)c.status==200?b.success(c.responseText):b.error(c.status,c.statusText)};c.send(b.data);return Bling([c])},post:function(f,b){if(isFunc(b))b={success:b};b=b||{};b.method="POST";return Bling.http(f,b)},get:function(f,b){if(isFunc(b))b={success:b};b=b||{};b.method="GET";return Bling.http(f,b)}});return{}});
Bling.module("Database",function(){function d(f,b){throw Error("sql error ["+b.code+"] "+b.message);}Bling.db=function(f,b,c,a){return Bling([window.openDatabase(f||"bling.db",b||"1.0",c||"bling database",a||1024)])};return{transaction:function(f){this.zip("transaction").call(f);return this},sql:function f(f,b,c,a){if(f!=undefined){if(typeof b=="function"){a=c;c=b;b=undefined}b=b||[];c=c||Function.Empty;a=a||d;assert(isType(this[0],"Database"),"can only call .sql() on a bling of Database");return this.transaction(function(e){e.executeSql(f,
b,c,a)})}}}});
Bling.module("Template",function(){function d(b,c){var a;if(!(a=arguments.callee.cache[b])){a=arguments.callee.cache;var e;a:{e=[];var g=b.split(/%[\(\/]/),h=-1,j=1,n=g.length;for(e.push(g[0]);j<n;j++){b:{h=g[j];var o=-1,l=1;if(o==null||o==-1)o=h.length;for(var m=0;m<o;m++){if(h.charAt(m)=="(")l+=1;else if(h.charAt(m)==")")l-=1;if(l==0){h=m;break b}}h=-1}if(h==-1){e="Template syntax error: unmatched '%(' in chunk starting at: "+g[j].substring(0,15);break a}key=g[j].substring(0,h);rest=g[j].substring(h);
match=f.exec(rest);if(match==null){e="Template syntax error: invalid type specifier starting at '"+rest+"'";break a}rest=match[4];e.push(key);e.push(match[1]|0);e.push(match[2]|0);e.push(match[3]);e.push(rest)}e=e}a=a[b]=e}a=a;e=[a[0]];j=g=1;for(n=a.length;j<n-4;j+=5){h=a[j];o=a[j+1];l=a[j+2];m=a[j+3];var k=a[j+4],p=c[h];if(p==null)p="missing required value: "+h;switch(m){case "d":e[g++]=""+parseInt(p);break;case "f":e[g++]=parseFloat(p).toFixed(l);break;default:e[g++]=""+p}if(o>0)e[g]=String.PadLeft(e[g],
o);e[g++]=k}return e.join("")}var f=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])(.*)/;d.cache={};return{template:function(b){b=Bling.extend({},b);this.render=function(c){return d(this.html().first(),Bling.extend(b,c))};return this.hide()}}});$=Bling;Bling.symbol="$";
