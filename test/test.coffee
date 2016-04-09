assert = require 'assert'

# Manual import since the lib isn't modular
fs = require 'fs'
CoffeeScript = require 'coffee-script'

# Stub
self = {
  addEventListener: ->
}

# Libraries
eval(fs.readFileSync("#{__dirname}/../src/adapter.js", "utf8"))
eval(CoffeeScript.compile(fs.readFileSync("#{__dirname}/../src/stdlib.coffee", 'utf8'), {bare: true}))
eval(CoffeeScript.compile(fs.readFileSync("#{__dirname}/../src/instruments.coffee", 'utf8'), {bare: true}))

describe('Instruments', ->
  describe('buildSample', ->
    it('should exist', ->
      assert(!!buildSample)
    )
  )
  describe('GlobalMixer', ->
    it('should exist', ->
      assert(!!GlobalMixer)
    )
  )
)
