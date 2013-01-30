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

		@listenTo Backbone, "ActiveBook", (book) => @activeBook = book 

		@listenTo Backbone, "OpenChapter", (chapter) => @activeChapter = chapter

		@$el.on "scroll", => Backbone.trigger "PreviewScrollTop", @$el.scrollTop()

		@$el.html @$content = $("<div />").addClass "content"
		this

	renderPreview: (md) ->
		env = {title: "##This is a title"}
		if @activeBook 
			totalEnv = @activeBook.get("env")
			env = us.extend env, 
				totalEnv["*"]
				totalEnv[@activeChapter.get "id"] or {}
				title: "###{@activeChapter.get "title"}"
			

		@$content.html markdown.toHTML us.template md, env

	setScroll: (amt) ->
		@$el.scrollTop amt

	scrollToBottom: ->
		@$el.scrollTop @$el[0].scrollHeight

module.exports = View