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
        
        routes = ({name : key, route : val} for key, val of map)
        for route in routes        
            iter = ""
            nested = []
            for spt in route.name.split(".")
                iter += spt
                nested.push routes.filter((f) -> f.name == iter)[0]
                iter += "."
            @_recognizer.add(nested.map((m) -> path: m.route.url, handler: {route : m.route, name : m.name}), { as: route.name })

        hasher.changed.add(@_hashChanged)
        hasher.initialized.add(@_hashChanged)
        hasher.init()

    go: (stateName, params) ->
        #TODO : now supported only one step above ^ !!!
        if stateName.indexOf("^") == 0
            stateName = @state.name.substring(0, @state.name.lastIndexOf(".")) + "." + stateName.substring(1)
        params = extend params, @state?.ctx.params            
        hash = @_recognizer.generate stateName, params
        hasher.setHash hash

    _hashChanged: (newHash, oldHash) =>    
        console.log "_hashChanged", newHash, oldHash 
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
                    if @opts.onBeforeChangeState(newState, previousState) != false                                    
                        @state = newState
                        @opts.onAfterChangeState(newState, previousState)
                else
                    @opts.onError err, newState
        else
            @opts.onNotFound newHash, @

window.Router = Router

