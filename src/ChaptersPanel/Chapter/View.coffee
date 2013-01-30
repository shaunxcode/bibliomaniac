class View extends Backbone.View

	render: ->
		@$el = $("<li />").text @model.get "title"
		@$el.append @$wordCount = $("<div />").addClass("wordCount").hide()
		@listenTo @$el, click: => @open() 
		
		@listenTo @model, "change", => 
			if wc = @model.get "wordCount"
				@$wordCount.text("Words: #{wc}").show()
			else
				@$wordCount.hide()
		this

	open: ->
		Backbone.trigger "OpenChapter", @model
		@$el.siblings().removeClass "active"
		@$el.addClass "active"

module.exports = View 