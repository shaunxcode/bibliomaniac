window.vendorRequire = (f) -> require "../vendor/#{f}.js"
window.dataRequire = (f) -> require "./data/#{f}.js"
window.appRequire = (f) -> require "./#{f}.js"
window.$ = window.jQuery = require "jquery"
window._ = require "underscore"
window.Backbone = vendorRequire "backbone"

vendorRequire "jquery.splitter"

ChaptersPanelView = require "./ChaptersPanel/View"
EditorView = require "./Editor/View"
PreviewView = require "./Preview/View"


App = 
	init: ->
		$ -> 
			@$hspliter = $("#panels").split orientation:"vertical", position: "50%", limit: 0

			$(window).on "resize", =>
				@$hspliter.trigger "spliter.resize"
				
			$(window).on "spliter.resize", -> Backbone.trigger "AppResized"

			@chaptersPanel = new ChaptersPanelView 
				el: $("#chapters")

			@chaptersPanel.render()

			@editor = new EditorView 
				el: $(".editor")

			@editor.render()

			@preview = new PreviewView
				el: $(".preview")

			@preview.render()

			Backbone.trigger "AppResized"
			
			console.log "Start the bibliomania!"

module.exports = App