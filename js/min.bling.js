(function(){var a,b,h,f,c,d,i,e,g=[].slice,j=[].indexOf||function(n){for(var m=0,k=this.length;m<k;m++){if(m in this&&this[m]===n){return m}}return -1};d=function(){var k;k=1<=arguments.length?g.call(arguments,0):[];try{return console.log.apply(console,k)}catch(l){}return alert(k.join(", "))};if((e=Object.keys)==null){Object.keys=function(n){var m,l;l=[];for(m in n){l.push(m)}return l}}h=function(m,l){var o,n;if(!l){return m}for(o in l){n=l[o];if(n!=null){m[o]=n}}return m};b=function(m,k,l){Object.defineProperty(m,k,h({configurable:true,enumerable:true},l));return m};c=function(k,l){if(!(l!=null)){return k===l||k==="null"||k==="undefined"}else{return l.constructor===k||l.constructor.name===k||Object.prototype.toString.apply(l)===("[object "+k+"]")||c(k,l.__proto__)}};f=function(k,l){if(typeof k==="function"){l.constructor=k;k=k.prototype}l.__proto__=k;return l};i=(function(){var o,l,p,k,n,m;l={};o={name:"unknown",match:function(q){return true}};k=[];n=function(q,r){if(!(q in l)){k.unshift(q)}return l[r.name=q]=o!==r?f(o,r):r};m=function(t,u){var s,q,r;if(typeof t==="string"){if((q=l[t])==null){l[t]=n(t,{})}return l[t]=h(l[t],u)}else{if(typeof t==="object"){r=[];for(s in t){r.push(m(s,t[s]))}return r}}};p=function(u){var s,t,r,q;for(t=0,r=k.length;t<r;t++){s=k[t];if((q=l[s])!=null?q.match.call(u,u):void 0){return l[s]}}};n("unknown",o);n("object",{match:function(){return typeof this==="object"}});n("error",{match:function(){return c("Error",this)}});n("regexp",{match:function(){return c("RegExp",this)}});n("string",{match:function(){return typeof this==="string"||c(String,this)}});n("number",{match:function(){return c(Number,this)}});n("bool",{match:function(){var q;return typeof this==="boolean"||((q=String(this))==="true"||q==="false")}});n("array",{match:function(){return(typeof Array.isArray==="function"?Array.isArray(this):void 0)||c(Array,this)}});n("function",{match:function(){return typeof this==="function"}});n("global",{match:function(){return typeof this==="object"&&"setInterval" in this}});n("undefined",{match:function(q){return q===void 0}});n("null",{match:function(q){return q===null}});return h((function(q){return p(q).name}),{register:n,lookup:p,extend:m,is:function(r,s){var q;return(q=l[r])!=null?q.match.call(s,s):void 0}})})();a=(function(){var l,m,k,n,o;n={};p.pipe=function(s,r){var t,v,u,q;v=(n[s]||(n[s]=[]));if(!r){return{prepend:function(w){v.unshift(w);return w},append:function(w){v.push(w);return w}}}for(u=0,q=v.length;u<q;u++){t=v[u];r=t.call(this,r)}return r};p.pipe("bling-init").prepend(function(r){var s,q;q=r[0],s=r[1];return f(p,h(i.lookup(q).array(q,s),{selector:q,context:s}))});l=typeof document!=="undefined"&&document!==null?document:{};function p(q,r){if(r==null){r=l}return p.pipe("bling-init",[q,r])}p.plugin=function(u,s){var r,t,v=this;if(!(s!=null)){s=u;u={}}if("depends" in u){return this.depends(u.depends,function(){return v.plugin({provides:u.provides},s)})}try{if((t=s!=null?s.call(this,this):void 0)){h(this,t!=null?t.$:void 0);["$","name"].forEach(function(w){return delete t[w]});h(this.prototype,t);for(r in t){this[r]||(this[r]=function(){var w;w=1<=arguments.length?g.call(arguments,0):[];return v.prototype[r].apply($(w[0]),w.slice(1))})}if(u.provides!=null){this.provide(u.provides)}}}catch(q){d("failed to load plugin: "+this.name+" '"+q.message+"'");throw q}return this};o=[];m={};k=function(q){return((typeof q)==="string"?q.split(","):q).filter(function(r){return !(r in m)})};p.depends=function(q,r){if((q=k(q)).length===0){r()}else{o.push(function(t){var s;return((s=q.indexOf(t))>-1?q.splice(s,1):void 0)&&q.length===0&&r})}return r};p.provide=function(t){var w,s,u,v,r,q;console.log("provide("+t+")");q=k(t);for(v=0,r=q.length;v<r;v++){u=q[v];m[u]=s=0;while(s<o.length){if((w=o[s](u))){o.splice(s,1);w()}else{s++}}}return null};p.provides=function(q,r){return function(){var s,t;s=1<=arguments.length?g.call(arguments,0):[];t=r.apply(null,s);p.provide(q);return t}};i.extend({unknown:{array:function(q){return[q]}},"null":{array:function(q){return[]}},undefined:{array:function(q){return[]}},array:{array:function(q){return q}},number:{array:function(q){return p.extend(new Array(q),{length:0})}}});i.register("bling",{match:function(q){return q&&c(p,q)},array:function(q){return q.toArray()},hash:function(q){return q.map(p.hash).sum()},string:function(q){return p.symbol+"(["+q.map(function(r){return $.type.lookup(r).string(r)}).join(", ")+"])"},repr:function(q){return p.symbol+"(["+q.map(function(r){return $.type.lookup(r).repr(r)}).join(", ")+"])"}});return p})();a.prototype=[];(function(k){var l;l=typeof window!=="undefined"&&window!==null?window:global;l.window=l;l.global=l;k.plugin({provides:"type"},function(){return{$:{inherit:f,extend:h,defineProperty:b,isType:c,type:i,is:i.is,isSimple:function(n){var m;return(m=i(n))==="string"||m==="number"||m==="bool"},isEmpty:function(m){return m===""||m===null||m===(void 0)}}}});k.plugin({provides:"symbol"},function(){var m,n;n=null;m={};l.Bling=k;b(k,"symbol",{set:function(o){l[n]=m[n];m[n=o]=l[o];return l[o]=a},get:function(){return n}});return{$:{symbol:"$"}}});k.plugin(function(){var q,o,p,n,m;(o=String.prototype).trimLeft||(o.trimLeft=function(){return this.replace(/^\s+/,"")});(p=String.prototype).split||(p.split=function(t){var r,u,s;r=[];u=0;while((s=this.indexOf(t,u))>-1){r.push(this.substring(u,s));u=s+1}return r});(n=String.prototype).lastIndexOf||(n.lastIndexOf=function(u,v,t){var r;if(t==null){t=-1}r=-1;while((t=u.indexOf(v,t+1))>-1){r=t}return r});(m=Array.prototype).join||(m.join=function(r){var u,t;if(r==null){r=""}u=this.length;if(u===0){return""}t=this[u-1];while(--u>0){t=this[u-1]+r+t}return t});if(typeof Event!=="undefined"&&Event!==null){Event.prototype.preventAll=function(){this.preventDefault();this.stopPropagation();return this.cancelBubble=true}}if(typeof Element!=="undefined"&&Element!==null){Element.prototype.matchesSelector=Element.prototype.webkitMatchesSelector||Element.prototype.mozMatchesSelector||Element.prototype.matchesSelector;if(Element.prototype.cloneNode.length===0){q=Element.prototype.cloneNode;Element.prototype.cloneNode=function(t){var u,w,v,s,r;if(t==null){t=false}w=q.call(this);if(t){r=this.childNodes;for(v=0,s=r.length;v<s;v++){u=r[v];w.appendChild(u.cloneNode(true))}}return w}}}return{}});k.plugin({depends:"function",provides:"delay"},function(){return{$:{delay:(function(){var m;m=k.extend([],(function(){var n;n=function(o){return function(){if(o.length){return o.shift()()}}};return{add:function(r,s){var p,q,o;r.order=s+k.now;for(p=q=0,o=this.length;q<=o;p=q+=1){if(p===this.length||this[p].order>r.order){this.splice(p,0,r);break}}setTimeout(n(this),s);return this},cancel:function(r){var p,q,o;for(p=q=0,o=this.length;q<o;p=q+=1){if(this[p]===r){this.splice(p,1);break}}return this}}})());return function(p,o){if(k.is("function",o)){m.add(o,p)}return{cancel:function(){return m.cancel(o)}}}})()},delay:function(p,m,o){if(o==null){o=this}return k.delay(p,k.bound(o,m))}}});k.plugin({provides:"core"},function(){var m;b(k,"now",{get:function(){return +(new Date)}});m=function(n,p){while(n<0){n+=p.length}return Math.min(n,p.length)};return{$:{log:d,assert:function(o,n){if(n==null){n=""}if(!o){throw new Error("assertion failed: "+n)}},coalesce:function(){var n;n=1<=arguments.length?g.call(arguments,0):[];return k(n).coalesce()}},eq:function(n){return k([this[m(n,this)]])},each:function(q){var o,p,n;for(p=0,n=this.length;p<n;p++){o=this[p];q.call(o,o)}return this},map:function(o){var n;return k((function(){var r,q,p;p=[];for(r=0,q=this.length;r<q;r++){n=this[r];p.push(o.call(n,n))}return p}).call(this))},reduce:function(s,p){var q,t,o,r;q=0;t=this.length;if(!(p!=null)){p=this[q++]}for(o=r=q;r<t;o=r+=1){p=s.call(this[o],p,this[o])}return p},union:function(o,r){var s,n,u,t,q,p;if(r==null){r=true}s=k();for(u=0,q=this.length;u<q;u++){n=this[u];if(!s.contains(n,r)){s.push(n)}}for(t=0,p=o.length;t<p;t++){n=o[t];if(!s.contains(n,r)){s.push(n)}}return s},distinct:function(n){if(n==null){n=true}return this.union(this,n)},intersect:function(o){var n;return k((function(){var r,q,p;p=[];for(r=0,q=this.length;r<q;r++){n=this[r];if(j.call(o,n)>=0){p.push(n)}}return p}).call(this))},contains:function(p,n){var o;if(n==null){n=true}return((function(){var s,r,q;q=[];for(s=0,r=this.length;s<r;s++){o=this[s];q.push((n&&o===p)||(!n&&o===p))}return q}).call(this)).reduce((function(r,q){return r||q}),false)},count:function(p,n){var o;if(n==null){n=true}return k((function(){var s,r,q;q=[];for(s=0,r=this.length;s<r;s++){o=this[s];if((p===void 0)||(n&&o===p)||(!n&&o===p)){q.push(1)}}return q}).call(this)).sum()},coalesce:function(){var p,q,o,n;for(q=0,o=this.length;q<o;q++){p=this[q];if((n=k.type(p))==="array"||n==="bling"){p=k(p).coalesce()}if(p!=null){return p}}return null},swap:function(p,o){var n;p=m(p,this);o=m(o,this);if(p!==o){n=[this[o],this[p]],this[p]=n[0],this[o]=n[1]}return this},shuffle:function(){var n;n=this.length-1;while(n>=0){this.swap(--n,Math.floor(Math.random()*n))}return this},select:(function(){var o,n;o=function(p){return function(){var q;if(k.is("function",q=this[p])){return k.bound(this,q)}else{return q}}};return n=function(r){var q;if((q=r.indexOf("."))>-1){return this.select(r.substr(0,q)).select(r.substr(q+1))}else{return this.map(o(r))}}})(),or:function(o){var p,q,n;for(p=q=0,n=this.length;q<n;p=q+=1){this[p]||(this[p]=o)}return this},zap:function(s,n){var r,q,o;q=s.lastIndexOf(".");if(q>0){r=s.substr(0,q);o=s.substr(q+1);this.select(r).zap(o,n);return this}switch(k.type(n)){case"array":case"bling":this.each(function(){return this[s]=n[++q%n.length]});break;case"function":this.zap(s,this.select(s).map(n));break;default:this.each(function(){return this[s]=n})}return this},take:function(q){var o,p;if(q==null){q=1}o=Math.min(q,this.length);return k((function(){var r,n;n=[];for(p=r=0;r<o;p=r+=1){n.push(this[p])}return n}).call(this))},skip:function(q){var o,p;if(q==null){q=0}p=Math.max(0,q|0);return k((function(){var s,n,r;r=[];for(o=s=p,n=this.length;s<n;o=s+=1){r.push(this[o])}return r}).call(this))},first:function(o){if(o==null){o=1}if(o===1){return this[0]}else{return this.take(o)}},last:function(o){if(o==null){o=1}if(o===1){return this[this.length-1]}else{return this.skip(this.length-o)}},slice:function(p,n){var o;if(p==null){p=0}if(n==null){n=this.length}p=m(p,this);n=m(n,this);return k((function(){var r,q;q=[];for(o=r=p;r<n;o=r+=1){q.push(this[o])}return q}).call(this))},extend:function(n){var p,q,o;for(q=0,o=n.length;q<o;q++){p=n[q];this.push(p)}return this},push:function(n){Array.prototype.push.call(this,n);return this},filter:function(o){var n;n=(function(){switch(k.type(o)){case"string":return function(p){return p.matchesSelector(o)};case"regexp":return function(p){return o.test(p)};case"function":return o;default:throw new Error("unsupported type passed to filter: "+(k.type(o)))}})();return k(Array.prototype.filter.call(this,n))},matches:function(n){return this.select("matchesSelector").call(n)},querySelectorAll:function(n){return this.filter("*").reduce(function(o,p){return o.extend(p.querySelectorAll(n))},k())},weave:function(o){var t,p,r,q,n,s;t=k();for(p=r=n=this.length-1;r>=0;p=r+=-1){t[(p*2)+1]=this[p]}for(p=q=0,s=o.length;q<s;p=q+=1){t[p*2]=o[p]}return t},fold:function(q){var o,p,r;r=this.length;o=k((function(){var t,n,s;s=[];for(p=t=0,n=r-1;t<n;p=t+=2){s.push(q.call(this,this[p],this[p+1]))}return s}).call(this));if((r%2)===1){o.push(q.call(this,this[r-1],void 0))}return o},flatten:function(){var n,r,q,t,s,p,o;n=k();for(t=0,p=this.length;t<p;t++){r=this[t];for(s=0,o=r.length;s<o;s++){q=r[s];n.push(q)}}return n},call:function(){return this.apply(null,arguments)},apply:function(o,n){return this.map(function(){if(k.is("function",this)){return this.apply(o,n)}else{return this}})},log:function(n){if(n){k.log(n,this.toString(),this.length+" items")}else{k.log(this.toString(),this.length+" items")}return this},toArray:function(){this.__proto__=Array.prototype;return this}}});k.plugin({provides:"math"},function(){return{$:{range:function(p,m,o){var n;if(o==null){o=1}if(m<p&&o>0){o*=-1}return k((function(){var s,q,r;r=[];for(n=s=0,q=Math.ceil((m-p)/o);0<=q?s<q:s>q;n=0<=q?++s:--s){r.push(p+(n*o))}return r})())},zeros:function(o){var m;return k((function(){var p,n;n=[];for(m=p=0;p<o;m=p+=1){n.push(0)}return n})())},ones:function(o){var m;return k((function(){var p,n;n=[];for(m=p=0;p<o;m=p+=1){n.push(1)}return n})())}},floats:function(){return this.map(parseFloat)},ints:function(){return this.map(function(){return parseInt(this,10)})},px:function(m){return this.ints().map(function(){return k.px(this,m)})},min:function(){return this.reduce(function(m){return Math.min(this,m)})},max:function(){return this.reduce(function(m){return Math.max(this,m)})},mean:function(){return this.sum()/this.length},sum:function(){return this.reduce(function(m){return m+this})},product:function(){return this.reduce(function(m){return m*this})},squares:function(){return this.map(function(){return this*this})},magnitude:function(){return Math.sqrt(this.floats().squares().sum())},scale:function(m){return this.map(function(){return m*this})},add:function(n){var m;switch(k.type(n)){case"number":return this.map(function(){return n+this});case"bling":case"array":return k((function(){var q,o,p;p=[];for(m=q=0,o=Math.min(this.length,n.length)-1;q<o;m=q+=1){p.push(this[m]+n[m])}return p}).call(this))}},normalize:function(){return this.scale(1/this.magnitude())}}});k.plugin({depends:"function",provides:"string"},function(){k.type.extend({unknown:{string:function(n){var m;return(m=typeof n.toString==="function"?n.toString():void 0)!=null?m:String(n)},repr:function(m){return k.type.lookup(m).string(m)}},"null":{string:function(){return"null"}},undefined:{string:function(){return"undefined"}},string:{string:k.identity,repr:function(m){return"'"+m+"'"}},array:{string:function(n){var m;return"["+((function(){var q,p,o;o=[];for(q=0,p=n.length;q<p;q++){m=n[q];o.push(k.toString(m))}return o})()).join(",")+"]"}},object:{string:function(p){var n,m;return"{"+((function(){var r,q,o;o=[];for(m=r=0,q=p.length;r<q;m=++r){n=p[m];o.push(""+n+":"+(k.toString(m)))}return o})()).join(", ")+"}"}},number:{repr:function(m){return String(m)},string:function(m){switch(true){case m.precision!=null:return m.toPrecision(m.precision);case m.fixed!=null:return m.toFixed(m.fixed);default:return String(m)}}}});return{$:{toString:function(m){if(!(m!=null)){return"function Bling(selector, context) { [ ... ] }"}else{return k.type.lookup(m).string(m)}},toRepr:function(m){return k.type.lookup(m).repr(m)},px:function(m,n){if(n==null){n=0}return(m!=null)&&(parseInt(m,10)+(n|0))+"px"},capitalize:function(m){return(m.split(" ").map(function(n){return n[0].toUpperCase()+n.substring(1).toLowerCase()})).join(" ")},dashize:function(o){var r,p,n,q,m;n="";for(p=q=0,m=(o!=null?o.length:void 0)|0;q<m;p=q+=1){r=o.charCodeAt(p);if((91>r&&r>64)){r+=32;n+="-"}n+=String.fromCharCode(r)}return n},camelize:function(m){var n;m.split("-");while((n=m!=null?m.indexOf("-"):void 0)>-1){m=k.stringSplice(m,n,n+2,m[n+1].toUpperCase())}return m},padLeft:function(m,p,o){if(o==null){o=" "}while(m.length<p){m=o+m}return m},padRight:function(m,p,o){if(o==null){o=" "}while(m.length<p){m=m+o}return m},stringCount:function(q,m,p,r){var o;if(p==null){p=0}if(r==null){r=0}if((o=q.indexOf(m,p))>p-1){return k.stringCount(q,m,o+1,r+1)}else{return r}},stringSplice:function(q,p,o,u){var m,t,r;t=q.length;m=o;if(m<0){m+=t}r=p;if(r<0){r+=t}return q.substring(0,r)+u+q.substring(m)},checksum:function(q){var o,n,p,r,m;o=1;n=0;for(p=r=0,m=q.length;0<=m?r<m:r>m;p=0<=m?++r:--r){o=(o+q.charCodeAt(p))%65521;n=(n+o)%65521}return(n<<16)|o},stringBuilder:function(){var m,n=this;if(k.is("window",this)){return new k.stringBuilder()}m=[];this.length=0;this.append=function(o){m.push(o);return n.length+=(o!=null?o.toString().length:void 0)|0};this.prepend=function(o){m.splice(0,0,o);return n.length+=(o!=null?o.toString().length:void 0)|0};this.clear=function(){var o;o=n.toString();m=[];n.length=0;return o};this.toString=function(){return m.join("")};return this}},toString:function(){return k.toString(this)},toRepr:function(){return k.toRepr(this)}}});k.plugin({provides:"function",depends:"hash"},function(){return{$:{identity:function(m){return m},not:function(m){return function(){return !m.apply(this,arguments)}},compose:function(n,m){return function(o){var p;return n.call(p,(p=m.call(o,o)))}},and:function(n,m){return function(o){return m.call(this,o)&&n.call(this,o)}},once:function(m,o){if(o==null){o=1}return k.defineProperty((function(){if(o-->0){return m.apply(this,arguments)}}),"exhausted",{get:function(){return o<=0}})},cycle:function(){var n,m;n=1<=arguments.length?g.call(arguments,0):[];m=-1;return function(){return n[m=++m%n.length].apply(this,arguments)}},bound:function(n,p,m){var o;if(m==null){m=[]}if(k.is("function",p.bind)){m.splice(0,0,n);o=p.bind.apply(p,m)}else{o=function(){var q;q=1<=arguments.length?g.call(arguments,0):[];return p.apply(n,m(m.length?void 0:q))}}return k.extend(o,{toString:function(){return"bound-method of "+n+"."+p.name}})},memoize:function(n){var m;m={};return function(){var q,p,o;q=1<=arguments.length?g.call(arguments,0):[];return(o=m[p=k.hash(q)])!=null?o:m[p]=n.apply(this,q)}}}}});k.plugin({provides:"hash",depends:"type"},function(){k.type.extend({unknown:{hash:function(m){return k.checksum(k.toString(m))}},object:{hash:function(n){var m;return((function(){var o;o=[];for(m in n){o.push(k.hash(n[m]))}return o})())+k.hash(Object.keys(n))}},array:{hash:function(n){var m;return((function(){var q,p,o;o=[];for(q=0,p=x.length;q<p;q++){m=x[q];o.push(k.hash(m))}return o})()).reduce(function(p,o){return p+o})}},bool:{hash:function(m){return parseInt(m?1:void 0)}}});return{$:{hash:function(m){return k.type.lookup(m).hash(m)}},hash:function(){return k.hash(this)}}});k.plugin({provides:"pubsub"},function(){var n,m,p,o;p={};n=function(){var s,v,u,t,r,q;v=arguments[0],s=2<=arguments.length?g.call(arguments,1):[];q=(p[v]||(p[v]=[]));for(t=0,r=q.length;t<r;t++){u=q[t];u.apply(null,s)}return s};m=function(r,q){(p[r]||(p[r]=[])).push(q);return q};o=function(t,s){var q,r;if(!(s!=null)){return p[t]=[]}else{q=(p[t]||(p[t]=[]));if((r=q.indexOf(s))>-1){return q.splice(r,r)}}};return{$:{publish:n,subscribe:m,unsubscribe:o}}});k.plugin({provides:"throttle",depends:"core"},function(){return{$:{throttle:function(o,p,m){if(p==null){p=250}if(m==null){m=0}return function(){var n,q;n=1<=arguments.length?g.call(arguments,0):[];q=k.now-m;if(q>p){m+=q;return o.apply(this,n)}return null}},debounce:function(o,p,m){if(p==null){p=250}if(m==null){m=0}return function(){var n,q;n=1<=arguments.length?g.call(arguments,0):[];m+=(q=k.now-m);return o.apply(this,n(q>p?void 0:null))}}}}});k.plugin({provides:"EventEmitter"},function(){return{$:{EventEmitter:k.pipe("bling-init").append(function(o){var n,m;m={};n=function(p){return m[p]||(m[p]=[])};return f(o,{emit:function(){var r,u,t,s,q,p;u=arguments[0],r=2<=arguments.length?g.call(arguments,1):[];p=n(u);for(s=0,q=p.length;s<q;s++){t=p[s];t.apply(this,r)}return null},addListener:function(q,p){n(q).push(p);return this.emit("newListener",q,p)},on:function(q,p){return this.addListener(q,p)},removeListener:function(r,q){var p;if((p=n(r).indexOf(q))>-1){return n(r).splice(p,1)}},removeAllListeners:function(p){return m[p]=[]},setMaxListeners:function(p){},listeners:function(p){return n(p).slice(0)}})})}}});if(l.document!=null){k.plugin({depends:"function",provides:"dom"},function(){var t,q,p,o,r,m,s,n;k.type.register("nodelist",{match:function(u){return(u!=null)&&k.isType("NodeList",u)},hash:function(v){var u;return k((function(){var z,y,w;w=[];for(z=0,y=x.length;z<y;z++){u=x[z];w.push(k.hash(u))}return w})()).sum()},array:k.identity,string:function(u){return"{Nodelist:["+k(u).select("nodeName").join(",")+"]}"},node:function(u){return k(u).toFragment()}});k.type.register("node",{match:function(u){return(u!=null?u.nodeType:void 0)>0},hash:function(u){return k.checksum(u.nodeName)+k.hash(u.attributes)+k.checksum(u.innerHTML)},string:function(u){return u.toString()},node:k.identity});k.type.register("fragment",{match:function(u){return(u!=null?u.nodeType:void 0)===11},hash:function(v){var u;return k((function(){var A,z,w,y;w=v.childNodes;y=[];for(A=0,z=w.length;A<z;A++){u=w[A];y.push(k.hash(u))}return y})()).sum()},string:function(u){return u.toString()},node:k.identity});k.type.register("html",{match:function(v){var u;return typeof v==="string"&&(u=v.trimLeft())[0]==="<"&&u[u.length-1]===">"},node:function(v){var u;return k.type.lookup(u=a.HTML.parse(v)).node(u)},array:function(v,w){var u;return k.type.lookup(u=a.HTML.parse(v)).array(u,w)},string:function(u){return"'"+u+"'"},repr:function(u){return'"'+u+'"'}});k.type.extend({unknown:{node:function(){return null}},bling:{node:function(u){return u.toFragment()}},string:{node:function(u){return k(u).toFragment()},array:function(u,v){return typeof v.querySelectorAll==="function"?v.querySelectorAll(u):void 0}},"function":{node:function(u){return k(u.toString()).toFragment()}}});s=function(u){var v;if(!(u.parentNode!=null)){v=document.createDocumentFragment();v.appendChild(u)}return u};q=function(v,u){return s(v).parentNode.insertBefore(u,v)};t=function(v,u){return s(v).parentNode.insertBefore(u,v.nextSibling)};n=function(u){return k.type.lookup(u).node(u)};o=null;p=function(u){return function(){return window.getComputedStyle(this,null).getPropertyValue(u)}};r=function(u){return function(v){if(v!=null){return this.css(u,v)}else{return this.rect().select(u)}}};m=function(u){return function(){return this.map(function(v){return k((function(){var w;w=[];while(v=v[u]){w.push(v)}return w})())})}};return{$:{HTML:{parse:function(v){var A,z,u,B,w,y;(w=document.createElement("div")).innerHTML=v;if(B=(A=w.childNodes).length===1){return w.removeChild(A[0])}z=document.createDocumentFragment();for(u=y=0;0<=B?y<B:y>B;u=0<=B?++y:--y){z.appendChild(w.removeChild(A[0]))}return z},stringify:function(w){var v,u;switch(k.type(w)){case"string":case"html":return w;case"node":case"fragment":v=document.createElement("div");v.appendChild((w=w.cloneNode(true)));u=v.innerHTML;v.removeChild(w);return u;default:return"HTML.stringify of unknown type: "+k.type(w)}},escape:function(v){var u;o||(o=k("<div>&nbsp;</div>").child(0));u=o.zap("data",v).select("parentNode.innerHTML").first();o.zap("data","");return u}}},html:function(u){switch(k.type(u)){case"undefined":case"null":return this.select("innerHTML");case"string":return this.zap("innerHTML",u);case"bling":return this.html(u.toFragment());case"node":return this.each(function(){var v;this.replaceChild(this.childNodes[0],u);v=[];while(this.childNodes.length>1){v.push(this.removeChild(this.childNodes[1]))}return v})}},append:function(u){u=n(u);return this.each(function(){return this.appendChild(u.cloneNode(true))})},appendTo:function(u){var w,v;w=this.map(function(){return this.cloneNode(true)});v=0;k(u).each(function(){return this.appendChild(w[v++])});return w},prepend:function(u){if(u!=null){u=n(u);this.take(1).each(function(){return q(this.childNodes[0],u)});this.skip(1).each(function(){return q(this.childNodes[0],u.cloneNode(true))})}return this},prependTo:function(u){if(u!=null){k(u).prepend(this)}return this},before:function(u){if(u!=null){u=n(u);this.take(1).each(function(){return q(this,u)});this.skip(1).each(function(){return q(this,u.cloneNode(true))})}return this},after:function(u){if(u!=null){u=n(u);this.take(1).each(function(){return t(this,u)});this.skip(1).each(function(){return t(this,u.cloneNode(true))})}return this},wrap:function(u){u=n(u);if(k.is("fragment",u)){throw new Error("cannot wrap with a fragment")}return this.each(function(y){var v,w;switch(k.type(y)){case"fragment":return u.appendChild(y);case"node":w=y.parentNode;if(!w){return u.appendChild(y)}else{v=document.createElement("dummy");u.appendChild(w.replaceChild(v,y));return w.replaceChild(u,v)}}})},unwrap:function(){return this.each(function(){if(this.parentNode&&this.parentNode.parentNode){return this.parentNode.parentNode.replaceChild(this,this.parentNode)}else{if(this.parentNode){return this.parentNode.removeChild(this)}}})},replace:function(A){var y,v,w,u,z;A=n(A);y=this.map(function(){return A.cloneNode(true)});for(v=w=0,u=y.length;w<u;v=w+=1){if((z=this[v].parentNode)!=null){z.replaceChild(y[v],this[v])}}return y},attr:function(u,w){switch(w){case void 0:return this.select("getAttribute").call(u,w);case null:return this.select("removeAttribute").call(u,w);default:this.select("setAttribute").call(u,w);return this}},data:function(w,u){return this.attr("data-"+(k.dashize(w)),u)},addClass:function(v){var u;u=function(w){return w!==""};return this.removeClass(v).each(function(){var w;w=this.className.split(" ").filter(u);w.push(v);return this.className=w.join(" ")})},removeClass:function(u){var v;v=function(w){return w!==u};return this.each(function(){var w;w=this.className.split(" ").filter(v).join(" ");if(w.length===0){return this.removeAttribute("class")}})},toggleClass:function(u){var v;v=function(w){return w!==u};return this.each(function(){var z,w,y;w=this.className.split(" ");y=k.not(k.isEmpty);if(w.indexOf(u)>-1){y=k.and(v,y)}else{w.push(u)}z=w.filter(y).join(" ");this.className=z;if(z.length===0){return this.removeAttribute("class")}})},hasClass:function(u){return this.select("className.split").call(" ").select("indexOf").call(u).map(function(v){return v>-1})},text:function(u){if(u!=null){return this.zap("textContent",u)}return this.select("textContent")},val:function(u){if(u!=null){return this.zap("value",u)}return this.select("value")},css:function(A,E){var D,C,u,F,w,z,B,y;if((E!=null)||k.is("object",A)){z=this.select("style.setProperty");if(k.is("object",A)){for(C in A){z.call(C,A[C],"")}}else{if(k.is("string",E)){z.call(A,E,"")}else{if(k.is("array",E)){for(C=B=0,y=u=Math.max(E.length,F=z.len());B<y;C=B+=1){z[C%F](A,E[C%u],"")}}}}return this}else{D=this.map(p(A));w=this.select("style").select(A);return w.weave(D).fold(function(v,G){return v||G})}},defaultCss:function(w,u){var y,A,z;A=this.selector;z="";if(k.is("string",w)){if(k.is("string",u)){z+=""+A+" { "+w+": "+u+" } "}else{throw Error("defaultCss requires a value with a string key")}}else{if(k.is("object",w)){for(y in w+"} "){z+=(""+A+" { ")+(""+y+": "+w[y]+"; ")}}}k("<style></style>").text(z).appendTo("head");return this},rect:function(){return this.select("getBoundingClientRect").call()},width:r("width"),height:r("height"),top:r("top"),left:r("left"),bottom:r("bottom"),right:r("right"),position:function(v,u){switch(true){case !(v!=null):return this.rect();case !(u!=null):return this.css("left",k.px(v));default:return this.css({top:k.px(u),left:k.px(v)})}},scrollToCenter:function(){document.body.scrollTop=this[0].offsetTop-(window.innerHeight/2);return this},child:function(u){return this.select("childNodes").map(function(){return this[u<0?u+this.length:u]})},parents:m("parentNode"),prev:m("previousSibling"),next:m("nextSibling"),remove:function(){return this.each(function(){var u;return(u=this.parentNode)!=null?u.removeChild(this):void 0})},find:function(u){return this.filter("*").map(function(){return k(u,this)}).flatten()},clone:function(u){if(u==null){u=true}return this.map(function(){if(k.is("node",this)){return this.cloneNode(u)}})},toFragment:function(){var u;if(this.length>1){u=document.createDocumentFragment();(this.map(n)).map(k.bound(u,u.appendChild));return u}return n(this[0])}}})}k.plugin({depends:"dom"},function(){var q,m,o,u,r,p,t,s,n;q=", ";o={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};m=/(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;n=30;u=document.createElement("div").style;r="transform";t="transition-property";p="transition-duration";s="transition-timing-function";if("WebkitTransform" in u){r="-webkit-transform";t="-webkit-transition-property";p="-webkit-transition-duration";s="-webkit-transition-timing-function"}else{if("MozTransform" in u){r="-moz-transform";t="-moz-transition-property";p="-moz-transition-duration";s="-moz-transition-timing-function"}else{if("OTransform" in u){r="-o-transform";t="-o-transition-property";p="-o-transition-duration";s="-o-transition-timing-function"}}}return{$:{duration:function(v){var w;w=o[v];if(w!=null){return w}return parseFloat(v)}},transform:function(B,v,A,D){var z,w,y,E,C,F;if(k.is("function",v)){D=v;v=A=null}else{if(k.is("function",A)){D=A;A=null}}if(v==null){v="normal"}A||(A="ease");w=k.duration(v)+"ms";C=[];F="";z={};for(y in B){if(m.test(y)){E=B[y];if(E.join){E=k(E).px().join(q)}else{if(E.toString){E=E.toString()}}F+=" "+y+"("+E+")"}else{z[y]=B[y]}}for(y in z){C.push(y)}if(F){C.push(r)}z[t]=C.join(q);z[p]=C.map(function(){return w}).join(q);z[s]=C.map(function(){return A}).join(q);if(F){z[r]=F}this.css(z);return this.delay(w,D)},hide:function(v){return this.each(function(){if(this.style){this._display="";if(this.style.display===!"none"){this._display=this.syle.display}return this.style.display="none"}}).trigger("hide").delay(n,v)},show:function(v){return this.each(function(){if(this.style){this.style.display=this._display;return delete this._display}}).trigger("show").delay(n,v)},toggle:function(v){return this.weave(this.css("display")).fold(function(y,w){if(y==="none"){w.style.display=w._display||"";delete w._display;k(w).trigger("show")}else{w._display=y;w.style.display="none";k(w).trigger("hide")}return w}).delay(n,v)},fadeIn:function(v,w){return this.css("opacity","0.0").show(function(){return this.transform({opacity:"1.0",translate3d:[0,0,0]},v,w)})},fadeOut:function(w,A,v,z){if(v==null){v=0}if(z==null){z=0}return this.transform({opacity:"0.0",translate3d:[v,z,0]},w,function(){return this.hide(A)})},fadeLeft:function(v,w){return this.fadeOut(v,w,"-"+this.width().first(),0)},fadeRight:function(v,w){return this.fadeOut(v,w,this.width().first(),0)},fadeUp:function(v,w){return this.fadeOut(v,w,0,"-"+this.height().first())},fadeDown:function(v,w){return this.fadeOut(v,w,0,this.height().first())}}});k.plugin({depends:"dom"},function(){var m;m=function(p){var n,q;q=JSON.parse(JSON.stringify(p));return((function(){var o;o=[];for(n in q){o.push(""+n+"="+(escape(q[n])))}return o})()).join("&")};k.type.register("http",{match:function(n){return k.isType("XMLHttpRequest",n)},array:function(n){return[n]}});return{$:{http:function(n,o){var p;if(o==null){o={}}p=new XMLHttpRequest();if(k.is("function",o)){o={success:k.bound(p,o)}}o=k.extend({method:"GET",data:null,state:k.identity,success:k.identity,error:k.identity,async:true,asBlob:false,timeout:0,followRedirects:false,withCredentials:false},o);o.state=k.bound(p,o.state);o.success=k.bound(p,o.success);o.error=k.bound(p,o.error);if(o.data&&o.method==="GET"){n+="?"+m(o.data)}else{if(o.data&&o.method==="POST"){o.data=m(o.data)}}p.open(o.method,n,o.async);p=k.extend(p,{asBlob:o.asBlob,timeout:o.timeout,followRedirects:o.followRedirects,withCredentials:o.withCredentials,onreadystatechange:function(){if(typeof o.state==="function"){o.state()}if(p.readyState===4){if(p.status===200){return o.success(p.responseText)}else{return o.error(p.status,p.statusText)}}}});p.send(o.data);return k(p)},post:function(n,o){if(o==null){o={}}if(k.is("function",o)){o={success:o}}o.method="POST";return k.http(n,o)},get:function(n,o){if(o==null){o={}}if(k.is("function",o)){o={success:o}}o.method="GET";return k.http(n,o)}}}});k.plugin({depends:"dom,function,core",provides:"event"},function(){var o,t,m,p,r,n,s,q;o=/,* +/;p=["mousemove","mousedown","mouseup","mouseover","mouseout","blur","focus","load","unload","reset","submit","keyup","keydown","change","abort","cut","copy","paste","selection","drag","drop","orientationchange","touchstart","touchmove","touchend","touchcancel","gesturestart","gestureend","gesturecancel","hashchange"];m=function(u){return function(v){return this.bind(u,v)(k.is("function",v)?void 0:this.trigger(u,v))}};r=function(u,w,v,z,y){return k(w).bind(v,y).each(function(){var A,B;return((A=((B=(this.__alive__||(this.__alive__={})))[u]||(B[u]={})))[v]||(A[v]={}))[z]=y})};q=function(u,v,z,y){var w;w=k(v);return w.each(function(){var B,A,C;B=(this.__alive__||(this.__alive__={}));A=(B[u]||(B[u]={}));C=(A[z]||(A[z]={}));w.unbind(z,C[y]);return delete C[y]})};s=k.once(function(){k(document).trigger("ready").unbind("ready");if(typeof document.removeEventListener==="function"){document.removeEventListener("DOMContentLoaded",s,false)}return typeof window.removeEventListener==="function"?window.removeEventListener("load",s,false):void 0});t=k.once(function(){if(typeof document.addEventListener==="function"){document.addEventListener("DOMContentLoaded",s,false)}return typeof window.addEventListener==="function"?window.addEventListener("load",s,false):void 0});t();n={bind:function(w,v){var y,u;y=(w||"").split(o);u=function(z){n=v.apply(this,arguments);if(n===false){z.preventAll()}return n};return this.each(function(){var B,C,A,z;z=[];for(C=0,A=y.length;C<A;C++){B=y[C];z.push(this.addEventListener(B,u,false))}return z})},unbind:function(v,u){var w;w=(v||"").split(o);return this.each(function(){var A,B,z,y;y=[];for(B=0,z=w.length;B<z;B++){A=w[B];y.push(this.removeEventListener(A,u,null))}return y})},trigger:function(w,y){var C,z,B,v,u;if(y==null){y={}}y=k.extend({bubbles:true,cancelable:true},y);u=(w||"").split(o);for(B=0,v=u.length;B<v;B++){z=u[B];if(z==="click"||z==="mousemove"||z==="mousedown"||z==="mouseup"||z==="mouseover"||z==="mouseout"){C=document.createEvent("MouseEvents");y=k.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},y);C.initMouseEvent(z,y.bubbles,y.cancelable,window,y.detail,y.screenX,y.screenY,y.clientX,y.clientY,y.ctrlKey,y.altKey,y.shiftKey,y.metaKey,y.button,y.relatedTarget)}else{if(z==="blur"||z==="focus"||z==="reset"||z==="submit"||z==="abort"||z==="change"||z==="load"||z==="unload"){C=document.createEvent("UIEvents");C.initUIEvent(z,y.bubbles,y.cancelable,window,1)}else{if(z==="touchstart"||z==="touchmove"||z==="touchend"||z==="touchcancel"){C=document.createEvent("TouchEvents");y=k.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},y);C.initTouchEvent(z,y.bubbles,y.cancelable,window,y.detail,y.screenX,y.screenY,y.clientX,y.clientY,y.ctrlKey,y.altKey,y.shiftKey,y.metaKey,y.touches,y.targetTouches,y.changedTouches,y.scale,y.rotation)}else{if(z==="gesturestart"||z==="gestureend"||z==="gesturecancel"){C=document.createEvent("GestureEvents");y=k.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},y);C.initGestureEvent(z,y.bubbles,y.cancelable,window,y.detail,y.screenX,y.screenY,y.clientX,y.clientY,y.ctrlKey,y.altKey,y.shiftKey,y.metaKey,y.target,y.scale,y.rotation)}else{C=document.createEvent("Events");C.initEvent(z,y.bubbles,y.cancelable);try{C=k.extend(C,y)}catch(A){}}}}}if(!C){continue}else{try{this.each(function(){return this.dispatchEvent(C)})}catch(A){d("dispatchEvent error:",A)}}}return this},live:function(z,y){var v,w,u;u=this.selector;v=this.context;w=function(A){return k(u,v).intersect(k(A.target).parents().first().union(k(A.target))).each(function(){return y.call(A.target=this,A)})};r(u,v,z,y,w);return this},die:function(v,u){k(this.context).unbind(v,q(this.selector,this.context,v,u));return this},click:function(v){var u;if(v==null){v={}}if((u=this.css("cursor"))==="auto"||u===""){this.css("cursor","pointer")}if(k.is("function",v)){return this.bind("click",v)}else{return this.trigger("click",v)}},ready:function(u){if(s.exhausted){return u.call(this)}return this.bind("ready",u)}};p.forEach(function(u){return n[u]=m(u)});return n});return k.plugin({depends:"dom",provides:"lazy"},function(){var m;m=function(n,o){return k("head").append(k.extend(document.createElement(n),o))};return{$:{script:function(n){return m("script",{src:n})},style:function(n){return m("link",{href:n,rel:"stylesheet"})}}}})})(a,this)}).call(this);