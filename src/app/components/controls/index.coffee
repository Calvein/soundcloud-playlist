View = require('bamjs/view')

tmpl = require('./index.jade')


class Controls extends View
    namespace: 'controls'

    events:
        'click .controls-title': 'clickTitle'
        'click [data-button=prev]': 'clickPrevTrack'
        'click [data-button=play]': 'clickPlayTrack'
        'click [data-button=next]': 'clickNextTrack'
        'click [data-button=shuffle]': 'clickShuffleTracks'
        'input .controls-timeline': 'inputTimeline'

    initialize: ->
        @$el.html(tmpl())

        # Store elements
        @$title = @$('.controls-title')
        @timeline = @$('.controls-timeline').get(0)
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
        @$title.text(@currentTrack.getTitle())
        # `audio.paused` is true when you change the src
        # So we need to force play when we play the next song
        isPlaying = forcePlay or !@audio.paused
        @$audio.one('canplaythrough', =>
            @seek(@currentTrack.getCurrentTime())
        )
        @$audio.attr('src', @currentTrack.getSrc())
        if isPlaying
            @audio.play()

    togglePlay: ->
        if @audio.paused
            @root().trigger('audio:play')
        else
            @root().trigger('audio:pause')

    prevTrack: ->
        $track = @$currentTrack.prevAll(':not(.hidden)').first()
        # Go to the last one if no prev track
        unless $track.get(0)
            $track = @$currentTrack.nextAll(':not(.hidden)').last()

        track = $track.data('track')
        @root().trigger('tracks:set', track)

    nextTrack: (e) ->
        $track = @$currentTrack.nextAll(':not(.hidden)').first()
        # Go to the first one if no next track
        unless $track.get(0)
            $track = @$currentTrack.prevAll(':not(.hidden)').last()

        track = $track.data('track')
        @root().trigger('tracks:set', track, e.type is 'ended')

    shuffleTracks: ->
        @root().trigger('playlist:shuffle')

        # Because we have to redraw the DOM
        @$currentTrack = @currentTrack.$el

    # Can be negative
    addSeconds: (seconds) -> @audio.currentTime += seconds


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
        duration = track.getDuration()
        @timeline.max = Math.round(duration / 1e3)
        if duration < 3e4
            @scrobbleIn = Infinity
        # We need to scrobble at at least 4 minutes played or half the song
        else
            @scrobbleIn = Math.min(duration / 2 / 1e3, 4 * 60)
        @currentTime = null
        @root().trigger('lastfm:nowPlaying', track)
        @goTo(forcePlay)

    play: ->
        @$el.addClass('playing')
        @audio.play()

    pause: ->
        @$el.removeClass('playing')
        @audio.pause()

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

        @timeline.value = @audio.currentTime
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
        # shift + ← => -5s
        else if e.shiftKey and e.keyCode is 37
            @addSeconds(-5)
        # shift + → => +5s
        else if e.shiftKey and e.keyCode is 39
            @addSeconds(5)


    # Events #
    clickTitle: (e) ->
        e.preventDefault()
        $('html, body').animate(
            scrollTop: @$currentTrack.offset().top - 10
        300)

    clickPrevTrack: (e) ->
        @prevTrack()

    clickPlayTrack: (e) ->
        @togglePlay()

    clickNextTrack: (e) ->
        @nextTrack(e)

    clickShuffleTracks: (e) ->
        @shuffleTracks()

    inputTimeline: (e) ->
        @seek(e.currentTarget.value)

module.exports = Controls