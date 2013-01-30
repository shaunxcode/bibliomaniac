class Collection extends Backbone.Collection
	model: require "./Model"

	initialize: (models, options) -> 
		@url = options.url 
		
module.exports = Collection