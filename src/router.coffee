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
        console.log recognized?[0].handler
        if recognized
            #collect all parent states params
            params = {}
            extend(params, rd.params) for rd in recognized            
            #resolve resolvers uhuh
            newState = getState recognized[recognized.length - 1], params
            previousState = @state
            @opts.onBeforeChangeState newState
            hasher.setHash newState.hash
            @opts.onAfterChangeState newState
        else
            @opts.onNotFound newHash

window.Router = Router

