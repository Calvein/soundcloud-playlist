View = require('bamjs/view')

tmpl = require('./index.jade')


class Controls extends View
    namespace: 'controls'

    events:
        'click .prev': 'prevTrack'
        'click .next': 'nextTrack'
        'click .delete': 'clickDelete'

    initialize: ->
        @$el.html(tmpl())

        # Init resusable elements
        @$title = @$('.title')
        @$audio = @$('audio')
        @audio = @$audio.get(0)

        # Add non DOM events
        @$audio.on('ended', @nextTrack.bind(@))

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
        @root().trigger('current:set', track)

    nextTrack: (e) ->
        track = @$current.next().data('track')
        @root().trigger('current:set', track, e.type is 'ended')


module.exports = Controls