###
spots = [
	{id : 0, name : "zero"},
	{id : 1, name : "one"},
	{id : 2, name : "two"}
]

map = 
	"spot" : 
		url : "spots/:spotId"
		resolve : (ctx, done) ->
			done spots.find((x) -> x.id == ctx.params.spotId)[0]
	"spot.main" :
		url : "main"
    "spot.main.edit" :
        url : "edit"        
	"spot.events" :
		url : "events"
	"spot.contacts" :
		url : "cotacts"        
	"spots" :
		url : "spots"
		resolve : (ctx, done) ->
			console.log ctx.query
			done spots

_first = (arr, pr) -> 
    for a in arr
        if pr(a) then return a         

_extend = (dest, src) ->
    if dest and src
        for s of src                    
            if !dest[s]
                dest[s] = src[s]
        return dest                
    else if dest or src
        return dest ? dest : src;
    else 
        return {}

resolveRoutes = (resolvers, ctx, done) ->
    if resolvers.length
        resolver ctx, (err) -> err ? done(err) : resolveRoutes(resolvers[1..], ctx, done)
    else
        done()
###

class Router

	constructor: (map, @opts) ->
        @_recognizer = new RouteRecognizer()
		(name : key, route : val for key, val of obj)
        .sort (a, b) -> a.name.localeCompare(b.name)
        .map (m) -> 
            @_recognizer.add path : m.url + "*", route : m
		
        hasher.changed.add(@_hashChanged);
		hasher.initialized.add(@_hashChanged);
		hasher.init()

	_hashChanged: (newHash, oldHash) ->    
        recognized = router.recognize newHash
        console.log recognized

###    
createRouteState: (route, params) ->
    ctx = 
        params : params
    hash = route.url
    for param of params
        hash = hash.replace(":" + param, params[param])
    route : route, ctx : ctx, hash : hash

getRoute: (statePath) =>
    if statePath[0] == "." or statePath[1] == "^"
        currentRouteIndex = @map.indexOf(@state.route)
        #relative path            
        if (statePath[0] == "^")            
            #get pervious
            return @map[currentRouteIndex - 1]
        if (statePath[0] == ".")            
            #next
            for route in @map[currentRouteIndex..]                    
                if route.name == @state.name + statePath
                    return route                        
    else
        #absoulte path
        return _first(@map, (f) -> f.name == statePath)

iterRouteResolvers: (state, done) ->        
    resolvedRoutes = []
    for path in state.name.split "."
        iter += iter ? path : "." + path
        route = _first(@map, (f) -> f.name == iter)            
        if route.resolve
            resolvedRoutes.push route
    resolveRoutes resolvedRoutes.map((m) -> m.resolver), ctx, done        

go: (state, params) ->
    route = getRoute state
    if route 
        sate = createRouteState state, params
        iterRouteResolvers state, (err) =>
            if !err
    			@state = state
    			hasher.setHash(hash)
            else
                if @opts.errorState
                    @go @opts.errorState
                else
                    throw new Error ("Router error")            
    else
        if @opts.notFoundState
            @go @opts.notFoundState
        else
            throw new Error ("Not found")                        
###                

window.Router = Router
