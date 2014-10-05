expect    = require 'expect.js'
path      = require 'path'
cheerio   = require 'cheerio'
_         = require 'lodash'

staticI18n      = require '../src/index'

describe 'processor', ->
  basepath = path.join __dirname, 'data'

  file = path.join basepath, 'index.html'
  options = {}

  beforeEach ->
    options = {localesPath: path.join(__dirname, 'data', 'locales')}

  describe '#process', ->
    input = '<p data-t="foo.bar"></p>'

    it 'should process all locales', (done) ->
      _.merge options, {locales: ['en', 'ja']}
      staticI18n.process input, options, (err, results) ->
        expect(results).to.only.have.keys ['ja', 'en']
        expect(results.ja).to.be '<p>ja_bar</p>'
        expect(results.en).to.be '<p>bar</p>'
        done()

  describe '#processFile', ->
    it 'should translate data-t', (done) ->
      staticI18n.processFile file, options, (err, results) ->
        $ = cheerio.load(results.en)
        expect($('#bar').text()).to.be 'bar'
        done()

    it 'should translate data-t content', (done) ->
      staticI18n.processFile file, options, (err, results) ->
        $ = cheerio.load(results.en)
        expect($('#baz').text()).to.be 'baz'
        expect($('#bar-replace > span').text()).to.be 'bar'
        done()

    it 'should replace', (done) ->
      options = _.defaults {replace: true}, options
      staticI18n.processFile file, options, (err, results) ->
        $ = cheerio.load(results.en)
        expect($('#bar').length).to.be 0
        expect($('#baz').length).to.be 0
        expect($('#bar-replace').html()).to.be 'bar'
        done()

    it 'should work with other selectors', (done) ->
      options = _.defaults {replace: true, selector: 't'}, options
      staticI18n.processFile file, options, (err, results) ->
        $ = cheerio.load(results.en)
        expect($('#bar-replace-sel').html()).to.be 'bar'
        done()


  describe '#processDir', ->
    it 'should process all files', (done) ->
      _.merge options, {locales: ['en', 'ja']}
      staticI18n.processDir basepath, options, (err, results) ->
        expect(results).to.only.have.keys ['index.html', 'other.html']
        expect(results['index.html']).to.only.have.keys ['en', 'ja']
        expect(results['other.html']).to.only.have.keys ['en', 'ja']
        $ = cheerio.load(results['index.html'].en)
        expect($('#bar').text()).to.be 'bar'
        done()