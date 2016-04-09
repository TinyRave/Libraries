assert = require 'assert'

# Manual import since the lib isn't modular
fs = require 'fs'
coffee = require 'coffee-script'

# Libraries
eval(fs.readFileSync("#{__dirname}/../src/adapter.js", "utf8"))
eval(CoffeeScript.compile(fs.readFileSync("#{__dirname}/../src/stdlib.coffee"), {bare: true}))
eval(CoffeeScript.compile(fs.readFileSync("#{__dirname}/../src/instruments.coffee"), {bare: true}))

describe('Instruments', ->
  describe('buildFunction', ->
    it('should exist', ->
      assert(!!buildFunction)
    )
  )
)

