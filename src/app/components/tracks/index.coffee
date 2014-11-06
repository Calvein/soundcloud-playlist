View = require('bamjs/view')
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
        @listenTo(@root(), 'playlist:new', @showPlaylist)
        @listenTo(@root(), 'playlist:shuffle', @shuffleTracks)
        @listenTo(@root(), 'audio:timeupdate', @audioTimeupdate)
        @listenTo(@root(), 'audio:progress', @audioProgress)

    showTracks: (tracks) ->
        @$el.html(tmpl(
            tracks: tracks
        ))

        for el in @$('.track')
            # Add the element to the track and vice-versa
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

        @$('.track-play.playing').removeClass('playing')
        track.$el.find('.track-play').addClass('playing')

    showPlaylist: (playlist) ->
        @tracks.add(playlist.tracks.reverse(),
            parse: true
        )

        @showTracks(@tracks.models)

    shuffleTracks: ->
        @showTracks(@tracks.shuffle())

    audioTimeupdate: (e) ->
        time = @root().audio.currentTime * 1e3
        @currentTrack.waveform.drawPlayed(time)

    audioProgress: (e) ->
        buffered = @root().audio.buffered
        last = buffered.length - 1
        from = buffered.start(last) * 1e3
        to = buffered.end(last) * 1e3
        @currentTrack.waveform.drawBuffered(from, to, last)


    # Events #
    clickTrackPlay: (e) ->
        $el = $(e.currentTarget)
        $track = $(e.currentTarget).parents('.track')
        if $track.hasClass('active') and @root().isPlaying()
            @root().trigger('audio:pause')
            $el.removeClass('playing')
        else
            # Swap icons
            @$('.track-play').removeClass('playing')
            $el.addClass('playing')
            track = $track.data('track')
            @root().trigger('tracks:set', track)
            @root().trigger('audio:play')

    clickTrackDelete: (e) ->
        e.preventDefault()
        e.stopPropagation()

        $track = $(e.currentTarget).parents('.track')
        track = $track.data('track')

        # If the current track is deleted, play the next one
        if $track.hasClass('active')
            nextTrack = $track.next().data('track')
            @root().trigger('tracks:set', nextTrack)

        $track.remove()
        @tracks.remove(track)

module.exports = Tracks