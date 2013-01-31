us = require "underscore"

class Text extends Backbone.View
	render: ->
		
		@$el.append(
			$("<label />").text(@options.label)
			$("<input />")
				.prop(type: "text")
				.val(@model.get @options.field))
		
		this

module.exports = Text