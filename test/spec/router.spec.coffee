describe "router: test", ->

    beforeEach ->
        hasher.setHash("")

    it "not found (default) path", ->

            map = 
                "spots" : 
                    url : "spots"

            router = new Router map, onNotFound: (_, router) -> router.go "spots"

            expect(router.state.name).toEqual("spots")

    describe "go", ->

        it "simple state go", ->

            map = 
                "spots" : 
                    url : "spots"

            router = new Router map

            spyOn(router.opts, "onBeforeChangeState")
            spyOn(router.opts, "onAfterChangeState")

            router.go "spots"     

            expected = 
                name : "spots",
                route : 
                    url  : "spots",
                ctx : 
                    params : {}
                    query : {}
                    resolved : {}

            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected, undefined)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected, undefined)
    

        it "relative state go", ->

            map = 
                "spot" :
                    url : "spots/:spotId"
                "spot.display" :
                    url : ""
                "spot.edit" :
                    url : "edit"

            router = new Router map

            router.go "spot.display", {spotId : "19"}        

            expect(router.state.name).toEqual("spot.display")
            expect(router.state.ctx.params).toEqual(spotId : "19")

            router.go "^edit"

            expect(router.state.name).toEqual("spot.edit")
            expect(router.state.ctx.params).toEqual(spotId : "19")
    
    describe "states resolvers", ->

        it "simple state resolve", ->

            map = 
                "spots" : 
                    url : "spots"
                    resolve : (ctx, done) ->
                        done(null, [])

            router = new Router map

            router.go "spots"

            expect(router.state.ctx.resolved.spots).toEqual([])

        it "children states with params resolve", ->

            map = 
                "spot" : 
                    url : "spots/:spotId"
                    resolve : (ctx, done) ->
                        done(null, {id : "yahooo"})                    
                "spot.display" :
                    url : ""
                "spot.edit" :
                    url : "edit"

            router = new Router map

            router.go "spot.display", {id : 19}        

            expect(router.state.ctx.resolved.spot).toEqual({id : "yahooo"})

	describe "states change", ->

		it "simple state change", ->
						
            map = 
                "spots" : 
                    url : "spots"


            router = new Router map

            spyOn(router.opts, "onBeforeChangeState")
            spyOn(router.opts, "onAfterChangeState")

            router.go "spots"		

            expected = 
                name : "spots",
                route : 
                    url  : "spots",
                ctx : 
                    params : {}
                    query : {}
                    resolved : {}

            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected, undefined)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected, undefined)


        it "children states with params change", ->
                        
            map = 
                "spot" : 
                    url : "spots/:spotId"
                "spot.display" :
                    url : ""
                "spot.edit" :
                    url : "edit"

            router = new Router map

            spyOn(router.opts, "onBeforeChangeState")
            spyOn(router.opts, "onAfterChangeState")

            router.go "spot.display", {spotId : "19"}        

            expected = 
                name : "spot.display",
                route : 
                    url  : "",
                ctx : 
                    params : {spotId : '19'}
                    query : {}
                    resolved : {}
                    
            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected, undefined)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected, undefined)


            router.go "spot.edit", {spotId : 19}        

            expected2 = 
                name : "spot.edit",
                route : 
                    url  : "edit",
                ctx : 
                    params : {spotId : '19'}
                    query : {}
                    resolved : {}
                    
            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected2, expected)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected2, expected)


            #router._hashChanged "/spots/19"





