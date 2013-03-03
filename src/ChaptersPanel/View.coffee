ChapterView = require "./Chapter/View"
TextInputView = appRequire "Input/Text"

modal = require "fluid-modal"

class View extends Backbone.View
	bookFields:
		title: label: "Title"
		description: label: "Description"
		authors: label: "Author(s)"
		publisher: label: "Publisher"
		publicationDate: label: "Publication Date"
		isbn: label: "ISBN"
		language: label: "Language"
		subject: label: "Subject"

	render: ->
		@chapterViews = []

		@$el.html @$topPanel = $("<div />").addClass("topPanel").append(
			@$newBookButton = $("<button />").text "new book"
			@$booksCombo = $("<select />")
			@$newChapterButton = $("<button />").text "new chapter"
			@$detailsButton = $("<button />").text "details"
			@$wordCount = $("<div />").addClass "wordCount")

		@$el.append @$holder = $("<div />").addClass("holder").html @$chapters = $("<ul />")

		@listenTo @collection, "reset", @addAll
		
		@$booksCombo.on "change", => 
			@renderChapters @collection.get @$booksCombo.val()

		@listenTo Backbone, "AppResized", => 
			@$holder.css height: @$el.innerHeight() - @$topPanel.outerHeight()

		@listenTo Backbone, "EditorChanged", @setWordCount

		modal.hide()
		modal.create()

		@listenTo @$detailsButton,
			click: => 
				modal.show()
				m = $(modal.content).html("")
				for field, detail of @bookFields
					view = new TextInputView 
						model: @activeBook
						field: field
						label: detail.label
					
					m.append view.render().$el

				m.append $("<div />").addClass("buttons").append(
					$("<button />").text("Cancel").on click: -> modal.hide()
					$("<button />").text("Save"))

		@listenTo Backbone, "escape", => 
			modal.hide()

	setWordCount: ->
		return if not @activeBook 

		wc = 0
		@activeBook.chapters.each (chapter) ->
			wc += chapter.get "wordCount"
		@$wordCount.text "Total Words: #{wc}"


	addAll: ->
		@$booksCombo.html ""
		@collection.each (book) => @addOne book
		@$booksCombo.change()

	addOne: (book) ->
		@$booksCombo.append $("<option />").prop 
			value: book.get("id")
			text: book.get("title")

	renderChapters: (book) ->
		@activeBook = book 

		@setWordCount()

		Backbone.trigger "ActiveBook", book 
		
		chap.remove() for chap in @chapterViews 
		
		@$chapters.html ""
		
		book.chapters.each (chapter) =>	 
			@chapterViews.push cview = new ChapterView model: chapter
			@$chapters.append cview.render().$el

module.exports = View