View = require('bamjs/view')
Form = require('./components/form')
Controls = require('./components/controls')
Tracks = require('./components/tracks')

class App extends View
    namespace: 'app'

    events:
        'keydown': 'keydown'

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

    isPlaying: -> !@controls.audio.paused

    # Events #
    keydown: (e) ->
        @trigger('keydown', e)


module.exports = App