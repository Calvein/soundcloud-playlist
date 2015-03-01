View = require('bamjs/view')
Sortable = require('sortablejs')
Waveform = require('../waveform')
{ shuffle } = require('bamjs/underscore')

TracksCollection = require('../../models/tracks')

tmpl = require('./index.jade')


class Tracks extends View
    namespace: 'tracks'

    events:
        'click .track-play': 'clickTrackPlay'
        'click [data-link=delete]': 'clickTrackDelete'

    initialize: ->
        @tracks = new TracksCollection()

        # Listeners #
        @listenTo(@root(), 'tracks:set', @setCurrent)
        @listenTo(@root(), 'tracks:reset', @deleteAllTracks)
        @listenTo(@root(), 'playlist:new', @showPlaylist)
        @listenTo(@root(), 'playlist:shuffle', @shuffleTracks)
        @listenTo(@root(), 'playlist:filter', @filterTracks)
        @listenTo(@root(), 'audio:timeupdate', @audioTimeupdate)
        @listenTo(@root(), 'audio:progress', @audioProgress)
        @listenTo(@root(), 'audio:play', @play)
        @listenTo(@root(), 'audio:pause', @pause)

    showTracks: (tracks) ->
        @$el.html(tmpl(
            tracks: tracks
        ))

        # Store elements
        $tracks = @$('.track')
        setTimeout(->
            $tracks.removeClass('showing')
        )

        # Make the track list sortable
        Sortable.create(@el,
            animation: 200
            # Toggle .sorting to prevent glitches caused by transitions
            onStart: (e) =>
                @$el.addClass('sorting')
            onEnd: (e) =>
                @$el.removeClass('sorting')
        )

        # Add the element to the track and vice-versa
        for el in $tracks
            $track = $(el)
            track = @tracks.get($track.data('track'))

            track.$el = $track
            $track.data('track', track)

            # Add waveform
            track.waveform = new Waveform(
                el: $('.track-waveform', el)
                parent: @
                model: track
            )

    # Listeners #
    setCurrent: (track) ->
        return if not track or @currentTrack is track
        @currentTrack = track
        track.$el.addClass('active')
            .siblings('.active').removeClass('active')

        @$('.playing').removeClass('playing')
        unless @root().audio.paused
            track.$el.addClass('playing')

    showPlaylist: (playlist) ->
        @tracks.add(playlist.tracks.reverse(),
            parse: true
            at: 0
        )

        @showTracks(@tracks.models)

    shuffleTracks: ->
        @showTracks(@tracks.shuffle())

    filterTracks: (filter) ->
        reg = new RegExp(filter, 'i')
        for track in @tracks.models
            hasName  = reg.test(track.getUsername())
            hasTitle = reg.test(track.get('title'))

            track.$el.toggleClass('hidden', !(hasName or hasTitle))

    audioTimeupdate: (e) ->
        time = @root().audio.currentTime * 1e3
        @currentTrack.waveform.drawPlayed(time)

    audioProgress: (e) ->
        buffered = @root().audio.buffered
        last = buffered.length - 1
        from = buffered.start(last) * 1e3
        to = buffered.end(last) * 1e3
        @currentTrack.waveform.drawBuffered(from, to, last)

    pause: ->
        @currentTrack.$el.removeClass('playing')

    play: ->
        # Swap icons
        @$('.playing').removeClass('playing')
        @currentTrack.$el.addClass('playing')

    playTrack: (track) ->
        $track = track.$el
        if $track.hasClass('active') and @root().isPlaying()
            @root().trigger('audio:pause')
        else
            # Swap icons
            @root().trigger('tracks:set', track)
            @root().trigger('audio:play')

    deleteTrack: (track, deleteAll) ->
        $track = track.$el
        # If the current track is deleted, play the next one
        if not deleteAll and $track.hasClass('active')
            nextTrack = $track.next().data('track')
            @root().trigger('tracks:set', nextTrack)

        $track.one('transitionend', =>
            $track.remove()
            @tracks.remove(track)
        ).addClass('delete')

    deleteAllTracks: ->
        for track in @tracks.models
            @deleteTrack(track, true)

    # Events #
    clickTrackPlay: (e) ->
        $el = $(e.currentTarget)
        $track = $(e.currentTarget).parents('.track')
        track = $track.data('track')
        @playTrack(track)

    clickTrackDelete: (e) ->
        e.preventDefault()
        e.stopPropagation()

        $track = $(e.currentTarget).parents('.track')
        track = $track.data('track')
        @deleteTrack(track)


module.exports = Tracks