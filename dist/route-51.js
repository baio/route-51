(function() {
  var Router, callResolvers, extend, getState,
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  extend = function(dest, src) {
    var prop;
    dest = dest || {};
    for (prop in src) {
      if (!hasProp.call(src, prop)) continue;
      if (dest[prop] === void 0) {
        dest[prop] = src[prop];
      }
    }
    return dest;
  };

  getState = function(route, params) {
    return {
      name: route.handler.name,
      route: route.handler.route,
      ctx: {
        params: params,
        query: route.query || {},
        resolved: {}
      }
    };
  };

  callResolvers = function(states, ctx, done) {
    if (!states.length) {
      done();
      return;
    }
    return states[0].route.resolve(ctx, function(err, res) {
      if (err) {
        return done(err);
      } else {
        ctx.resolved[states[0].name] = res;
        return callResolvers(states.slice(1), ctx, done);
      }
    });
  };

  Router = (function() {
    function Router(map, opts) {
      this._hashChanged = bind(this._hashChanged, this);
      var iter, j, k, key, len, len1, nested, ref, route, routes, spt, val;
      this.opts = extend(opts, {
        onBeforeChangeState: function() {},
        onAfterChangeState: function() {},
        onNotFound: function(state) {
          return console.log("State not found", state);
        },
        onError: function(err, state) {
          throw err;
        }
      });
      this._recognizer = new RouteRecognizer();
      routes = (function() {
        var results;
        results = [];
        for (key in map) {
          val = map[key];
          results.push({
            name: key,
            route: val
          });
        }
        return results;
      })();
      for (j = 0, len = routes.length; j < len; j++) {
        route = routes[j];
        iter = "";
        nested = [];
        ref = route.name.split(".");
        for (k = 0, len1 = ref.length; k < len1; k++) {
          spt = ref[k];
          iter += spt;
          nested.push(routes.filter(function(f) {
            return f.name === iter;
          })[0]);
          iter += ".";
        }
        this._recognizer.add(nested.map(function(m) {
          return {
            path: m.route.url,
            handler: {
              route: m.route,
              name: m.name
            }
          };
        }), {
          as: route.name
        });
      }
      hasher.changed.add(this._hashChanged);
      hasher.initialized.add(this._hashChanged);
      hasher.init();
    }

    Router.prototype.isState = function(stateMatch) {
      if (this.state) {
        return stateMatch === this.state.name || (new RegExp("^" + stateMatch + "[/.]")).test(this.state.name);
      } else {
        return false;
      }
    };

    Router.prototype.go = function(stateName, params) {
      var hash, ref;
      if (stateName.indexOf("^") === 0) {
        stateName = this.state.name.substring(0, this.state.name.lastIndexOf(".")) + "." + stateName.substring(1);
      }
      params = extend(params, (ref = this.state) != null ? ref.ctx.params : void 0);
      hash = this._recognizer.generate(stateName, params);
      return hasher.setHash(hash);
    };

    Router.prototype._hashChanged = function(newHash, oldHash) {
      var i, j, len, newState, params, rd, recognized, resolveStates;
      console.log("_hashChanged", newHash, oldHash);
      recognized = this._recognizer.recognize(newHash);
      if (recognized) {
        recognized = (function() {
          var j, ref, results;
          results = [];
          for (i = j = 0, ref = recognized.length - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
            results.push(recognized[i]);
          }
          return results;
        })();
        params = {};
        for (j = 0, len = recognized.length; j < len; j++) {
          rd = recognized[j];
          extend(params, rd.params);
        }
        newState = getState(recognized[recognized.length - 1], params);
        resolveStates = recognized.map(function(m) {
          return m.handler;
        }).filter(function(f) {
          return f.route.resolve;
        });
        return callResolvers(resolveStates, newState.ctx, (function(_this) {
          return function(err) {
            var previousState;
            if (!err) {
              previousState = _this.state;
              if (_this.opts.onBeforeChangeState(newState, previousState) !== false) {
                _this.state = newState;
                return _this.opts.onAfterChangeState(newState, previousState);
              }
            } else {
              return _this.opts.onError(err, newState);
            }
          };
        })(this));
      } else {
        return this.opts.onNotFound(newHash, this);
      }
    };

    return Router;

  })();

  window.Router = Router;

}).call(this);
