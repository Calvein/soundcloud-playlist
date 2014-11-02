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
        @$title = @$('.controls-title')
        @root().$audio = @$audio = @$('audio')
        @root().audio =  @audio  = @$audio.get(0)

        # Trigger useful audio events
        events = [
            'ended'
            'progress'
            'timeupdate'
        ]
        events.forEach((eventName) =>
            @$audio.on(eventName, (e) =>
                @root().trigger('audio:' + eventName, e)
            )
        )

        # Listeners #
        @listenTo(@root(), 'tracks:set', @setCurrent)
        @listenTo(@root(), 'audio:ended', @nextTrack)
        @listenTo(@root(), 'audio:play', @play)
        @listenTo(@root(), 'audio:pause', @pause)
        @listenTo(@root(), 'audio:seek', @seek)
        @listenTo(@root(), 'keydown', @keydown)

    goTo: (forcePlay) ->
        # `audio.paused` is true when you change the src
        isPlaying = forcePlay or !@audio.paused
        @$audio.attr('src', @currentTrack.get('src'))
        @$title.text(@currentTrack.get('title'))
        if isPlaying
            @audio.play()

    togglePlay: ->
        if @audio.paused then @audio.play() else @audio.pause()


    # Listeners #
    play: -> @audio.play()

    pause: -> @audio.pause()

    seek: (time) -> @audio.currentTime = time

    setCurrent: (track, forcePlay) ->
        return if @currentTrack is track
        @$el.removeAttr('hidden')
        @currentTrack = track

        if @currentTrack
            @$currentTrack = track.$el
            @goTo(forcePlay)
        else
            # Remove and pause
            @audio.src = ''

    keydown: (e) ->
        # space: toggle play/pause
        # Not when focus, except when on a play/pause button
        if e.keyCode is 32 and $(':focus:not(.track-play)').length is 0
            e.preventDefault()
            @togglePlay()


    # Events #
    prevTrack: (e) ->
        track = @$currentTrack.prev().data('track')
        @root().trigger('tracks:set', track)

    nextTrack: (e) ->
        track = @$currentTrack.next().data('track')
        @root().trigger('tracks:set', track, e.type is 'ended')

    shuffleTracks: (e) ->
        @root().trigger('playlist:shuffle')

        # Because we have to redraw the DOM
        @$currentTrack = @currentTrack.$el


module.exports = Controls