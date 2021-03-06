View = require('bamjs/view')
User = require('./models/user')
Lasftfm = require('./components/lastfm')
Forms = require('./components/forms')
Controls = require('./components/controls')
Tracks = require('./components/tracks')
{ throttle } = require('bamjs/underscore')

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

        resize = throttle(@resize.bind(@), 50)
        $(window).on('resize', resize)

    isPlaying: -> !@controls.audio.paused

    # Events #
    resize: (e) ->
        @trigger('resize', e)

    keydown: (e) ->
        @trigger('keydown', e)


module.exports = App