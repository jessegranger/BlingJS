// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function($) {
    var engines, match_forward;
    engines = {};
    $.plugin(function() {
      var current_engine, template;
      current_engine = null;
      engines = {};
      template = {
        register_engine: function(name, render_func) {
          engines[name] = render_func;
          if (!(current_engine != null)) {
            return current_engine = name;
          }
        },
        render: function(text, args) {
          if (current_engine in engines) {
            return engines[current_engine](text, args);
          }
        }
      };
      template.__defineSetter__('engine', function(v) {
        if (!v in engines) {
          throw new Error("invalid template engine: " + v + " not one of " + (Object.Keys(engines)));
        } else {
          return current_engine = v;
        }
      });
      template.__defineGetter__('engine', function() {
        return current_engine;
      });
      return {
        name: 'Template',
        $: {
          template: template
        }
      };
    });
    $.template.register_engine('null', (function() {
      return function(text, values) {
        return text;
      };
    })());
    match_forward = function(text, find, against, start, stop) {
      var count, i, t, _i;
      if (stop == null) {
        stop = -1;
      }
      count = 1;
      if (stop < 0) {
        stop = text.length + 1 + stop;
      }
      for (i = _i = start; start <= stop ? _i < stop : _i > stop; i = start <= stop ? ++_i : --_i) {
        t = text[i];
        if (t === against) {
          count += 1;
        } else if (t === find) {
          count -= 1;
        }
        if (count === 0) {
          return i;
        }
      }
      return -1;
    };
    $.template.register_engine('pythonic', (function() {
      var chunk_re, compile, render, type_re;
      type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;
      chunk_re = /%[\(\/]/;
      compile = function(text) {
        var chunks, end, i, j, key, match, n, rest, ret, _i;
        chunks = text.split(chunk_re);
        n = chunks.length;
        ret = [chunks[0]];
        j = 1;
        for (i = _i = 1; 1 <= n ? _i < n : _i > n; i = 1 <= n ? ++_i : --_i) {
          end = match_forward(chunks[i], ')', '(', 0, -1);
          if (end === -1) {
            return "Template syntax error: unmatched '%(' starting at: " + (chunks[i].substring(0, 15));
          }
          key = chunks[i].substring(0, end);
          rest = chunks[i].substring(end);
          match = type_re.exec(rest);
          if (match === null) {
            return "Template syntax error: invalid type specifier starting at '" + rest + "'";
          }
          rest = match[4];
          ret[j++] = key;
          ret[j++] = match[1] | 0;
          ret[j++] = match[2] | 0;
          ret[j++] = match[3];
          ret[j++] = rest;
        }
        return ret;
      };
      compile.cache = {};
      render = function(text, values) {
        var cache, fixed, i, j, key, n, output, pad, rest, type, value, _i, _ref, _ref1;
        cache = compile.cache[text];
        if (!(cache != null)) {
          cache = compile.cache[text] = compile(text);
        }
        output = [cache[0]];
        j = 1;
        n = cache.length;
        for (i = _i = 1, _ref = n - 5; _i <= _ref; i = _i += 5) {
          _ref1 = cache.slice(i, (i + 4) + 1 || 9e9), key = _ref1[0], pad = _ref1[1], fixed = _ref1[2], type = _ref1[3], rest = _ref1[4];
          value = values[key];
          if (!(value != null)) {
            value = "missing value: " + key;
          }
          switch (type) {
            case 'd':
              output[j++] = "" + parseInt(value, 10);
              break;
            case 'f':
              output[j++] = parseFloat(value).toFixed(fixed);
              break;
            case 's':
              output[j++] = "" + value;
              break;
            default:
              output[j++] = "" + value;
          }
          if (pad > 0) {
            output[j] = String.PadLeft(output[j], pad);
          }
          output[j++] = rest;
        }
        return output.join("");
      };
      return render;
    })());
    return $.template.register_engine('js-eval', (function() {
      var TemplateMachine;
      TemplateMachine = (function(_super) {

        __extends(TemplateMachine, _super);

        function TemplateMachine() {
          return TemplateMachine.__super__.constructor.apply(this, arguments);
        }

        TemplateMachine.STATE_TABLE = [
          {
            enter: function() {
              this.data = [];
              return this.GO(1);
            }
          }, {}
        ];

        return TemplateMachine;

      })($.StateMachine);
      return function(text, values) {
        return text;
      };
    })());
  })(Bling);

}).call(this);