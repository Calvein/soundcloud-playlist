View = require('bamjs/view')
{ shuffle } = require('bamjs/underscore')

TracksCollection = require('../../models/tracks')

tmpl = require('./index.jade')


class Tracks extends View
    namespace: 'tracks'

    events:
        'click .track-play': 'clickTrackPlay'
        'click .track-delete': 'clickTrackDelete'

    initialize: ->
        @tracks = new TracksCollection()

        # Listeners #
        @listenTo(@root(), 'current:set', @setCurrent)
        @listenTo(@root(), 'playlist:new', @showPlaylist)
        @listenTo(@root(), 'playlist:shuffle', @shuffleTracks)

    showTracks: (tracks) ->
        console.log tracks
        @$el.html(tmpl(
            tracks: tracks
        ))

        # Add the element to the track and vice-versa
        for el in @$('.track')
            $track = $(el)
            track = @tracks.get($track.data('id'))

            track.$el = $track
            $track.data('track', track)


    # Listeners #
    setCurrent: (track) ->
        return unless track
        track.$el.addClass('active')
            .siblings('.active').removeClass('active')

        @$('.track-play.playing').removeClass('playing')
        track.$el.find('.track-play').addClass('playing')

    showPlaylist: (playlist) ->
        @tracks.add(playlist.tracks)
        # Show the last added first
        @showTracks(@tracks.models.reverse())

    shuffleTracks: ->
        @showTracks(@tracks.shuffle())


    # Events #
    clickTrackPlay: (e) ->
        e.stopPropagation()
        $el = $(e.currentTarget)
        $track = $(e.currentTarget).parents('.track')
        if $track.hasClass('active') and @root().isPlaying
            @root().trigger('pause')
            $el.removeClass('playing')
        else
            # Swap icons
            @$('.track-play').removeClass('playing')
            $el.addClass('playing')
            track = $track.data('track')
            @root().trigger('current:set', track)
            @root().trigger('play')

    clickTrackDelete: (e) ->
        e.preventDefault()
        e.stopPropagation()

        $track = $(e.currentTarget).parents('.track')

        # If the current track is deleted, play the next one
        if $track.hasClass('active')
            track = $track.next().data('track')
            @root().trigger('current:set', track)

        $track.remove()

module.exports = Tracks