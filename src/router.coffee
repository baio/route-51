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

callResolvers = (resolvers, ctx, done) ->
    if !resolvers.length 
        done()
        return

    resolvers[0] ctx, (err) ->
        if err 
            done err
        else if resolvers.length
            callResolvers resolvers[1..], ctx, done

class Router

    constructor: (map, opts) ->
        @opts = extend opts, {
            onBeforeChangeState: ->
            onAfterChangeState: ->                
            onNotFound: (state) -> new Error "State not found", state                  
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
            resolvers = recognized.map((m) -> m.handler.route.resolve).filter((f) -> f)
            callResolvers resolvers, newState.ctx, (err) => 
                if !err
                    previousState = @state
                    @opts.onBeforeChangeState newState            
                    hasher.setHash newState.hash
                    @opts.onAfterChangeState newState
                    @state = newState
                else
                    throw err
        else
            @opts.onNotFound newHash

window.Router = Router

