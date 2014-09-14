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
        @root().on('keydown', @keydown.bind(@))

    goTo: (forcePlay) ->
        # `audio.paused` is true when you change the src
        isPlaying = forcePlay or !@audio.paused
        @$audio.attr('src', @current.get('src'))
        @$title.text(@current.get('title'))
        if isPlaying
            @audio.play()

    togglePlay: ->
        if @audio.paused then @audio.play() else @audio.pause()


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

    keydown: (e) ->
        # space: toggle play/pause
        if e.keyCode is 32 and $(':focus').length is 0
            e.preventDefault()
            @togglePlay()


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