describe "router: test", ->

    describe "states resolvers", ->

        it "simple state resolve", ->

            map = 
                "spots" : 
                    url : "spots"
                    resolve : (ctx, done) ->
                        done(null, [])

            router = new Router map

            router._hashChanged "/spots"        

            expect(router.state.ctx.resolved.spots).toEqual([])


	describe "states change", ->

		it "simple state change", ->
						
            map = 
                "spots" : 
                    url : "spots"


            router = new Router map

            spyOn(router.opts, "onBeforeChangeState")
            spyOn(router.opts, "onAfterChangeState")

            router._hashChanged "/spots"		

            expected = 
                name : "spots",
                route : 
                    url  : "spots",
                ctx : 
                    params : {}
                    query : {}

            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected)


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

            router._hashChanged "spots/19"        

            expected = 
                name : "spot.display",
                route : 
                    url  : "",
                ctx : 
                    params : {spotId : '19'}
                    query : {}
                    
            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected)


            router._hashChanged "spots/19/edit"        

            expected = 
                name : "spot.edit",
                route : 
                    url  : "edit",
                ctx : 
                    params : {spotId : '19'}
                    query : {}
                    
            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected)


            #router._hashChanged "/spots/19"





