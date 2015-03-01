View = require('bamjs/view')
User = require('./models/user')
Lasftfm = require('./components/lastfm')
Forms = require('./components/forms')
Controls = require('./components/controls')
Tracks = require('./components/tracks')

class App extends View
    namespace: 'app'

    events:
        'keydown': 'keydown'

    initialize: ->
        # Init user
        @user = new User()

        # Init components
        @lastfm = new Lasftfm(
            el: @$('.lastfm')
            model: @user
            parent: @
        )

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