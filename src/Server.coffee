express = require "express"
fs = require "fs"
app = express()
server = app.listen 6633
booksDir = "example"
Book = require "./Bibliomaniac"
getBook = (book) -> new Book booksDir, book

app.configure ->
	app.use express.static "./public"

	app.get "/books", (req, res) ->
		books = []
		for file in fs.readdirSync booksDir 
			books.push getBook(file).toJSON()

		res.send books

	app.get "/books/:book", (req, res) =>		
		res.send getBook(req.params.book).toJSON()

	app.get "/books/:book/chapters/:chapter", (req, res) =>		
		res.send getBook(req.params.book).getChapter req.params.chapter

	app.get "/*", (req, res) -> res.sendfile "./public/index.html"
