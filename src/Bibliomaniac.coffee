edn = require "jsedn"
md = require "markdown"
fs = require "fs"
us = require "underscore"
ent = require "ent"
us.templateSettings = 
	escape: /\{\{(.+?)\}\}/g
	evaluate: /\[\[(.+?)\]\]/g
	interpolate: /\[\{(.+?)\}\]/g


reAmp = (str) -> str.replace /\&amp\;/g, "&"

tmpls = "./templates"
templates = {}
for tmpl in fs.readdirSync tmpls
	templates[tmpl.split(".")[0]] = us.template fs.readFileSync "#{tmpls}/#{tmpl}", "utf-8"

class Book 
	toJSON: -> 
		toc = @toc()
		for chap in toc
			us.extend chap, wordCount: @getChapterSource(chap.id).split(/\s+/).length

		us.extend @settings(), id: @book, toc: toc

	constructor: (@bookDir, @book) ->
		@bookFile = @bookDir + "/#{@book}/book.edn"
		@data = book = edn.toJS edn.readFileSync @bookFile
		@data.env or= {"*": {}}

	settings: ->
		settings = {}
		for key, val of @data when @data isnt "toc"
			settings[key] = val
		settings 

	toc: ->
		range = [0..@data.toc.length - 1]
		(for title, i in range by 2
			id: @data.toc[i], title: @data.toc[i + 1])

	getChapterInToc: (chapId) ->
		for chap in @toc() when chap.id is chapId
			return chap

	isInToc: (chapId) ->
		@getChapterInToc(chapId)?

	getChapterSource: (name) ->
		if not @isInToc name
			return false

		fileName = "#{@bookDir}/#{@book}/#{name}.md"
		if not fs.existsSync fileName
			fs.writeFileSync fileName, "{{title}}\n\nchapter about #{name}"
		fs.readFileSync fileName, "utf-8"


	getChapter: (chapId) ->
		if chap = @getChapterInToc chapId
			us.extend chap, source: @getChapterSource chapId

	setChapter: (chapId, chapter) ->
		#eventually write title back to edn
		if chap = @getChapterInToc chapId
			fs.writeFileSync "#{@bookDir}/#{@book}/#{chapId}.md", chapter.source

	prep: (outputDirName) -> 
		if fs.existsSync outputDirName
			for file in fs.readdirSync outputDirName
				fs.unlinkSync "#{outputDirName}/#{file}"
			fs.rmdirSync outputDirName

		outputDir = fs.mkdirSync outputDirName

		spineItems = ""
		manifestItems = ""
		navMapItems = ""
		tocItems = ""
		playOrder = 1
		tocName = "Table of Contents"
		guideItems = templates.guideItem 
			type: "toc"
			title: "Table of Contents"
			link: "toc.html"

		for chapter in @toc()
			chap = chapter.id
			title = chapter.title 

			console.log "Reading #{chap}, #{title}" 
			if chap is "toc"
				tocName = title
			else
				mdtxt = @getChapterSource chap
				content = reAmp md.parse ent.encode us.template mdtxt, 
					us.extend {title: "###{title}\n"}, 
						@data.env["*"]
						@data.env[chap] or {}

				fs.writeFileSync "#{outputDirName}/#{chap}.html", templates.chapter {content}

			navMapItems += "\n" + reAmp templates.navMapItem
				id: chap 
				playOrder: playOrder++
				title: ent.encode title
				link: "#{chap}.html" 
			
			spineItems += "\n" + templates.spineItem name: chap

			manifestItems += "\n" + templates.manifestItem 
				id: chap
				link: "#{chap}.html"
				mediaType: "application/xhtml+xml"

			tocItems += "\n" + reAmp templates.tocItem link: "#{chap}.html", title: ent.encode title

			if chap is @data.bookStarts 
				guideItems += "\n" + templates.guideItem 
					type: "text"
					title: ent.encode title
					link: "#{chap}.html"


		creatorItems = ""
		for author in @data.authors 
			creatorItems += "\n" + templates.creator {author}
		
		manifestItems += "\n" + templates.manifestItem 
			id: coverImageId = "#{@data.name}_Cover"
			mediaType: "image/gif"
			link: @data.coverImage

		manifestItems += "\n" + templates.manifestItem
			id: "My_Table_of_Contents"
			mediaType: "application/x-dtbncx+xml"
			link: "#{@data.name}.ncx"

		console.log "Creating opf"
		fs.writeFileSync "#{outputDirName}/#{@data.name}.opf", templates.opf 
			name: @data.name
			title: @data.title 
			language: @data.language 
			coverImageId: coverImageId
			isbn: @data.isbn
			creatorItems: creatorItems
			publisher: @data.publisher
			subject: @data.subject
			publicationDate: @data.publicationDate 
			description: @data.description 
			manifestItems: manifestItems
			spineItems: spineItems
			guideItems: guideItems

		console.log "Creating ncx"
		fs.writeFileSync "#{outputDirName}/#{@data.name}.ncx", templates.ncx 
			name: @data.name
			title: @data.title
			language: @data.language
			author: @data.authors[0]
			navMapItems: navMapItems

		console.log "Creating table of contents"
		fs.writeFileSync "#{outputDirName}/toc.html", templates.toc 
			title: ent.encode tocName
			tocItems: tocItems

		console.log "Copy cover image"
		fs.createReadStream("./content/#{@data.coverImage}")
			.pipe(fs.createWriteStream("#{outputDirName}/#{@data.coverImage}"))

		true

module.exports = Book