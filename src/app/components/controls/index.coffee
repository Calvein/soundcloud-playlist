View = require('bamjs/view')

tmpl = require('./index.jade')


class Controls extends View
    namespace: 'controls'

    events:
        'click [data-direction=prev]': 'prevTrack'
        'click [data-direction=next]': 'nextTrack'
        'click [data-type=shuffle]': 'shuffleTracks'

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
        @$audio.attr('src', @current.get('src'))
        @$title.text(@current.get('title'))
        if isPlaying
            @audio.play()


    # Listeners #
    setCurrent: (track, forcePlay) ->
        @$el.removeAttr('hidden')
        @current = track

        if @current
            @$current = track.$el
            @goTo(forcePlay)
        else
            # Remove and pause
            @audio.src = ''


    # Events #
    prevTrack: (e) ->
        track = @$current.prev().data('track')
        @root().trigger('current:set', track)

    nextTrack: (e) ->
        track = @$current.next().data('track')
        @root().trigger('current:set', track, e.type is 'ended')

    shuffleTracks: (e) ->
        @root().trigger('playlist:shuffle')

        # Because we have to redraw the DOM
        @$current = @current.$el


module.exports = Controls