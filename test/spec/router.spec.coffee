describe "router: test", ->

	describe "absolute states", ->

		it "`#/spots` hash which correspons `spots` state should find correct route", ->
						
            map = 
                "spots" : 
                    url : "spots"


            router = new Router map

            spyOn(router.opts, "onBeforeChangeState")
            spyOn(router.opts, "onAfterChangeState")

            router._hashChanged "/spots"		

            expected = 
                name : "spots",
                hash : "spots"
                route : 
                    url  : "spots",
                ctx : 
                    params : {}
                    query : {}
            expect(router.opts.onBeforeChangeState).toHaveBeenCalledWith(expected)
            expect(router.opts.onAfterChangeState).toHaveBeenCalledWith(expected)



            #router._hashChanged "/spots/19"





