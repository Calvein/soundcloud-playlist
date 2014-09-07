View = require('bamjs/view')

tmpl = require('./index.jade')


class Controls extends View
    namespace: 'controls'

    events:
        '.prev click': 'prevTrack'
        '.next click': 'nextTrack'
        'audio ended': 'nextTrack'

    initialize: ->
        @$el.html(tmpl())

        # Init resusable elements
        @$title = @$('.title')
        @$audio = @$('audio')
        @audio = @$audio.get(0)

        # Listeners #
        @root().on('current:set', @setCurrent.bind(@))

    goTo: (forcePlay) ->
        # `audio.paused` is true when you change the src
        isPlaying = forcePlay or !@audio.paused
        @$audio.attr('src', @current.src)
        @$title.text(@current.title)
        if isPlaying
            @audio.play()


    # Listeners #
    setCurrent: (track, forcePlay) ->
        @$el.removeAttr('hidden')
        @current = track
        @$current = track.$el

        @goTo(forcePlay)


    # Events #
    prevTrack: (e) ->
        track = @$current.prev().data('track')
        @root().trigger('current:change', track)


    nextTrack: (e) ->
        track = @$current.next().data('track')
        @root().trigger('current:change', track, e.type is 'ended')


module.exports = Controls