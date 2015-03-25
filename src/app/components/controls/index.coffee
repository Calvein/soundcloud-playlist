View = require('bamjs/view')

tmpl = require('./index.jade')


class Controls extends View
    namespace: 'controls'

    events:
        'click .controls-title': 'clickTitle'
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
        audioEvents = [
            'ended'
            'progress'
            'timeupdate'
        ]
        audioEvents.forEach((eventName) =>
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
        @listenTo(@root(), 'audio:timeupdate', @timeupdate)
        @listenTo(@root(), 'keydown', @keydown)

    goTo: (forcePlay) ->
        @$title.text(@currentTrack.get('title'))
        # `audio.paused` is true when you change the src
        # So we need to force play when we play the next song
        isPlaying = forcePlay or !@audio.paused
        @$audio.one('canplaythrough', =>
            @seek(@currentTrack.get('currentTime'))
        )
        @$audio.attr('src', @currentTrack.get('src'))
        if isPlaying
            @audio.play()

    togglePlay: ->
        if @audio.paused
            @root().trigger('audio:play')
        else
            @root().trigger('audio:pause')


    # Listeners #
    setCurrent: (track, forcePlay) ->
        @$el.removeClass('init')

        return if @currentTrack is track
        @root().currentTrack = @currentTrack = track

        unless track
            # It remove and pause
            @audio.src = ''
            return

        @$currentTrack = track.$el

        # For scrobbling
        track.set('startPlaying', Date.parse(new Date().toUTCString()))
        # Duration has to be 30s mininum
        if track.get('duration') < 3e4
            @scrobbleIn = Infinity
        # We need to scrobble at at least 4 minutes played or half the song
        else
            @scrobbleIn = Math.min(
                track.get('duration') / 2 / 1e3
                4 * 60
            )
        @currentTime = null
        @root().trigger('lastfm:nowPlaying', track)
        @goTo(forcePlay)

    play: -> @audio.play()

    pause: -> @audio.pause()

    seek: (time) ->
        @audio.currentTime = time
        @currentTime = @audio.currentTime

    timeupdate: ->
        # Fist time playing
        if @currentTime is null
            @currentTime = @audio.currentTime
        # Change the scrobbled time
        else
            @scrobbleIn -= @audio.currentTime - @currentTime
            @currentTime = @audio.currentTime

        # When the user listen enough of the song (@see setCurrent)
        # we trigger the scrobbling
        if @scrobbleIn <= 0
            # We prevent the song to scrobble again while it's still playing
            @scrobbleIn = Infinity
            @root().trigger('lastfm:scrobble', @currentTrack)

        @currentTrack.set('currentTime', @audio.currentTime)

    keydown: (e) ->
        return if $('input:focus').length
        # space: toggle play/pause
        # Not when focus, except when on a play/pause button
        if e.keyCode is 32 and $(':focus:not(.track-play)').length is 0
            e.preventDefault()
            @togglePlay()
        # J or ctrl + ← => prev
        else if e.keyCode is 74 or e.ctrlKey and e.keyCode is 37
            @prevTrack()
        # K or ctrl + → => next
        else if e.keyCode is 75 or e.ctrlKey and e.keyCode is 39
            @nextTrack()


    # Events #
    clickTitle: (e) ->
        e.preventDefault()
        $('html, body').animate(
            scrollTop: @$currentTrack.offset().top - 10
        300)

    prevTrack: (e = {}) ->
        $track = @$currentTrack.prevAll(':not(.hidden)').first()
        # Go to the last one if no prev track
        unless $track.get(0)
            $track = @$currentTrack.nextAll(':not(.hidden)').last()

        track = $track.data('track')
        @root().trigger('tracks:set', track)

    nextTrack: (e = {}) ->
        $track = @$currentTrack.nextAll(':not(.hidden)').first()
        # Go to the first one if no next track
        unless $track.get(0)
            $track = @$currentTrack.prevAll(':not(.hidden)').last()

        track = $track.data('track')
        @root().trigger('tracks:set', track, e.type is 'ended')

    shuffleTracks: (e) ->
        @root().trigger('playlist:shuffle')

        # Because we have to redraw the DOM
        @$currentTrack = @currentTrack.$el


module.exports = Controls