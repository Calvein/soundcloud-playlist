View = require('bamjs/view')
Forms = require('./components/forms')
Controls = require('./components/controls')
Tracks = require('./components/tracks')

class App extends View
    namespace: 'app'

    events:
        'keydown': 'keydown'

    initialize: ->
        # Init components
        @forms = new Forms(
            el: @$('.forms')
            parent: @
        )

        @controls = new Controls(
            el: @$('.controls')
            parent: @
        )

        @tracks = new Tracks(
            el: @$('.tracks')
            parent: @
        )

    isPlaying: -> !@controls.audio.paused

    # Events #
    keydown: (e) ->
        @trigger('keydown', e)


module.exports = App