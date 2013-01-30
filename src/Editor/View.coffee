
class View extends Backbone.View

	render: ->
		@$el.html ""

		codemirror = require "code-mirror"

		@editor = codemirror @$el[0], 
			mode: "markdown"
			lineNumbers: true
			lineWrapping: true
			onChange: => 
				Backbone.trigger "EditorChanged", @editor.getValue()
			onScroll: =>
				Backbone.trigger "EditorScrollTop", @$scroller.scrollTop()
				if @$scroller.scrollTop() is (@$scroller[0].scrollHeight - @$scroller[0].offsetHeight)
					Backbone.trigger "EditorScrollAtBottom"

		@$scroller = @$ ".CodeMirror-scroll"

		@$scrollingPanes = @$ ".CodeMirror, .CodeMirror-scroll, .CodeMirror-scrollbar"

		@listenTo Backbone, "AppResized", => 
			@$scrollingPanes.css 
				height: @$el.innerHeight() 
				width: @$el.innerWidth()
			@editor.setValue @editor.getValue()

		@listenTo Backbone, "PreviewScrollTop", @setScroll

		this

	setScroll: (amt) ->
		@editor.scrollTo 0, amt

module.exports = View