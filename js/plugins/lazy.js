
  (function($) {
    return $.plugin(function() {
      var create, lazy_load;
      create = function(elementName, props) {
        return Object.Extend(document.createElement(elementName), props);
      };
      lazy_load = function(elementName, props) {
        var depends, n, provides;
        depends = provides = null;
        n = create(elementName, Object.Extend(props, {
          "onload!": function() {
            if (provides != null) return $.publish(provides);
          }
        }));
        $("head").delay(10, function() {
          var _this = this;
          if (depends != null) {
            return $.subscribe(depends, function() {
              return _this.append(n);
            });
          } else {
            return this.append(n);
          }
        });
        n = $(n);
        return Object.Extend(n, {
          depends: function(tag) {
            depends = elementName + "-" + tag;
            return n;
          },
          provides: function(tag) {
            provides = elementName + "-" + tag;
            return n;
          }
        });
      };
      return {
        name: "LazyLoader",
        $: {
          script: function(src) {
            return lazy_load("script", {
              "src!": src
            });
          },
          style: function(src) {
            return lazy_load("link", {
              "href!": src,
              "rel!": "stylesheet"
            });
          }
        }
      };
    });
  })(Bling);
