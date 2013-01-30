ChaptersCollection = require "./Chapter/Collection"

class Model extends Backbone.Model


	initialize: ->
		@chapters = new ChaptersCollection @get("toc"), url: "#{@url()}/chapters"


module.exports = Model