ChapterView = require "./Chapter/View"

class View extends Backbone.View
	render: ->
		@$el.html @$booksCombo = $("<select />")	
		@$el.append @$chapters = $("<ul />")
		@chapterViews = []
		@listenTo @collection, "reset", @addAll
		@$booksCombo.on "change", => 
			@renderChapters @collection.get @$booksCombo.val()


	addAll: ->
		@$booksCombo.html ""
		@collection.each (book) => @addOne book
		@$booksCombo.change()

	addOne: (book) ->
		@$booksCombo.append $("<option />").prop 
			value: book.get("id")
			text: book.get("title")

	renderChapters: (book) ->
		Backbone.trigger "ActiveBook", book 
		
		chap.remove() for chap in @chapterViews 
		
		@$chapters.html ""
		
		book.chapters.each (chapter) =>	 
			@chapterViews.push cview = new ChapterView model: chapter
			@$chapters.append cview.render().$el

module.exports = View