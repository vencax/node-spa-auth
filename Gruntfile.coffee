module.exports = (grunt) ->

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  grunt.initConfig

    coffeelint:
      app: ["{,*/}*.coffee"]

    jshint:
      all: ["lib/**/*.js", "index.js"]

    mochaTest:
      test:
        options:
          require: ["coffee-script"]

        src: ["test/main.coffee"]

  grunt.registerTask "test", ["jshint", "coffeelint", "mochaTest:test"]
  grunt.registerTask "default", ["test"]
