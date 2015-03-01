describe "router: test", ->

	describe "absolute states", ->

		it "simple state", ->
						
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


        it "children states with params", ->
                        
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





