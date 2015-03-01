"use strict"

module.exports = (config) ->

  config.set

    preprocessors:
      "src/**.coffee": ["coffee"]
      "test/spec/**/*.coffee": ["coffee"]  

    coffeePreprocessor: 
      options: 
        bare: false,
        sourceMap: true
        debug: false
      transformPath: (path) ->
        path.replace(/\.coffee$/, '.js')

    frameworks: ['jasmine']

    files: [
      "bower_components/route-recognizer/dist/route-recognizer.js",
      "bower_components/js-signals/dist/signals.js",
      "bower_components/hasher/dist/js/hasher.js",
      "src/**/*.coffee",
      "test/spec/**/*.spec.coffee"
    ]

    reporters: ['progress']
    browsers: ['Chrome']
    logLevel: config.LOG_DEBUG
    autoWatch: true

    singleRun: false
    colors: true
