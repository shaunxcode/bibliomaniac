modal = require "fluid-modal"

class View extends Backbone.View

	render: ->
		@$el = $("<li />").text @model.get "title"
		@$el.append @$wordCount = $("<div />").addClass("wordCount").hide()
		@$el.append @$details = $("<button />").text("d").addClass("details").hide()

		@listenTo @$el, 
			click: => @open() 
			mouseover: => @$details.show()
			mouseleave: => @$details.hide()
		
		@listenTo @model, "change", => @setWordCount()


		modal.hide()
		modal.create()

		@listenTo @$details,
			click: => 
				modal.show()
				$(modal.content).html "STUFF"

		@listenTo Backbone, "escape", -> modal.hide()
	
		@setWordCount()
				
		this

	setWordCount: -> 
		@$wordCount.text("Words: #{@model.get "wordCount"}").show()

	open: ->
		Backbone.trigger "OpenChapter", @model
		@$el.siblings().removeClass "active"
		@$el.addClass "active"

module.exports = View 