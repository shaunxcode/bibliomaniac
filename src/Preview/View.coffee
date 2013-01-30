markdown = require "markdown"
us = require "underscore"
us.templateSettings = 
	escape: /\{\{(.+?)\}\}/g
	evaluate: /\[\[(.+?)\]\]/g
	interpolate: /\[\{(.+?)\}\]/g

class View extends Backbone.View

	render: ->
		@$el.html "Markdown preview"

		@listenTo Backbone, "EditorChanged", @renderPreview

		@listenTo Backbone, "EditorScrollTop", @setScroll

		@listenTo Backbone, "EditorScrollAtBottom", @scrollToBottom

		@$el.on "scroll", => Backbone.trigger "PreviewScrollTop", @$el.scrollTop()

		this

	renderPreview: (md) ->
		@$el.html markdown.toHTML us.template md, title: "##This is a title"

	setScroll: (amt) ->
		@$el.scrollTop amt

	scrollToBottom: ->
		@$el.scrollTop @$el[0].scrollHeight

module.exports = View