View = require('bamjs/view')
Form = require('./components/form')
Controls = require('./components/controls')
Tracks = require('./components/tracks')

class App extends View
    namespace: 'app'

    initialize: ->
        # Init components
        @form = new Form(
            el: @$('form')
            parent: @
        )

        @controls = new Controls(
            el: @$('.controls')
            parent: @
        )

        @track = new Tracks(
            el: @$('.tracks')
            parent: @
        )

        # Get default playlist
        @trigger('playlist:get')


module.exports = App