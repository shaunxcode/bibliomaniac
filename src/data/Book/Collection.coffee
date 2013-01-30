class Collection extends Backbone.Collection
	url: "/books"
	model: require "./Model"

module.exports = Collection