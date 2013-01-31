markdown = require "markdown"
us = require "underscore"
us.templateSettings = 
	escape: /\{\{(.+?)\}\}/g
	evaluate: /\[\[(.+?)\]\]/g
	interpolate: /\[\{(.+?)\}\]/g

dims = 
	web: w: "100%", h: "100%"
	kindle: w: "758px", h: "1024px"
	kindleFire: w: "800px", h: "1200px"
	ipad: w: "320px", h: "480px"
	ipadMini: w: "768px", h: "1024px"
	iphone: w: "320px", h: "480px"

class View extends Backbone.View

	events:
		"click button": "sizeToggle"

	render: ->
		@$el.html "Markdown preview"

		@listenTo Backbone, "EditorChanged", @renderPreview

		@listenTo Backbone, "EditorScrollTop", @setScroll

		@listenTo Backbone, "EditorScrollAtBottom", @scrollToBottom

		@listenTo Backbone, "ActiveBook", (book) => @activeBook = book 

		@listenTo Backbone, "OpenChapter", (chapter) => @activeChapter = chapter

		@$el.on "scroll", => 
			if @$el.scrollTop() >= (@$el[0].scrollHeight - @$el[0].offsetHeight) - 1
				Backbone.trigger "PreviewScrollAtBottom"
			else
				Backbone.trigger "PreviewScrollTop", @$el.scrollTop()

		@$el.html @$content = $("<div />").addClass "content"

		@$el.append @$sizeToggles = $("<div />").addClass("sizeToggles").append(
			$("<button />").text("web").data(type: "web").addClass "active"
			$("<button />").text("kindle").data(type: "kindle")
			$("<button />").text("kindle fire").data(type: "kindleFire")
			$("<button />").text("ipad").data(type: "ipad")
			$("<button />").text("ipad mini").data(type: "ipadMini")
			$("<button />").text("iphone").data(type: "iphone"))


		this

	sizeToggle: (event) ->
		$button = $(event.currentTarget)
		$button.siblings().removeClass "active"
		$button.addClass "active"
		dim = dims[$button.data("type")]
		@$content.css width: dim.w

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