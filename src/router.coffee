nextMatch = (match, routes) ->
    for route in routes                 
        if !route then continue
        console.log ">>", route

        #get nested (if starts with the same shit, then nested)
        nested = routes.filter (f) ->                 
            f.name.indexOf(route.name + ".") == 0
        routes[routes.indexOf(nd)] = null for nd in nested                            

        _subRoute = (_match) ->            
            nextMatch _match, nested            

        match("/" + route.route.url).to {name : route.name, route : route.route}, if nested.length then _subRoute

extend = (dest, src) ->
    dest = dest || {}
    for own prop of src        
        dest[prop] = src[prop] if dest[prop] == undefined
    dest

getState = (route, params) ->
    name : route.handler.name
    route : route.handler.route
    ctx : 
        params : params
        query : route.query || {}
        resolved : {}

callResolvers = (states, ctx, done) ->
    if !states.length 
        done()
        return

    states[0].route.resolve ctx, (err, res) ->
        if err 
            done err
        else
            ctx.resolved[states[0].name] = res
            callResolvers states[1..], ctx, done

class Router

    constructor: (map, opts) ->
        @opts = extend opts, {
            onBeforeChangeState: ->
            onAfterChangeState: ->                
            onNotFound: (state) -> console.log "State not found", state 
            onError: (err, state) -> throw err
        };


        @_recognizer = new RouteRecognizer()
        @_recognizer.map (match) ->
            nextMatch match, ({name : key, route : val} for key, val of map)

        hasher.changed.add(@_hashChanged)
        hasher.initialized.add(@_hashChanged)
        hasher.init()


    _hashChanged: (newHash, oldHash) =>    
        recognized = @_recognizer.recognize newHash
        if recognized
            recognized = (recognized[i] for i in [0..recognized.length - 1])
            #collect states params
            params = {}
            extend(params, rd.params) for rd in recognized                    
            newState = getState recognized[recognized.length - 1], params        
            #find resolvers
            resolveStates = recognized.map((m) -> m.handler).filter((f) -> f.route.resolve)
            callResolvers resolveStates, newState.ctx, (err) => 
                if !err
                    previousState = @state
                    if @opts.onBeforeChangeState(newState) != false            
                        hasher.setHash newState.hash
                        @opts.onAfterChangeState newState
                        @state = newState
                else
                    @opts.onError err, newState
        else
            @opts.onNotFound newHash

window.Router = Router

