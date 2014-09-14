View = require('bamjs/view')
{ shuffle } = require('bamjs/underscore')

TracksCollection = require('../../models/tracks')

tmpl = require('./index.jade')


class Tracks extends View
    namespace: 'tracks'

    events:
        'click .track': 'clickTrack'
        'click .delete': 'clickDelete'

    initialize: ->
        @tracks = new TracksCollection()

        # Listeners #
        @root().on('current:set', @setCurrent.bind(@))
        @root().on('playlist:new', @showPlaylist.bind(@))
        @root().on('playlist:shuffle', @shuffleTracks.bind(@))

    showTracks: (tracks, showFirst) ->
        @$el.html(tmpl(
            tracks: tracks
        ))

        # Add the element to the track and vice-versa
        for el in @$('.track')
            $track = $(el)
            track = @tracks.get($track.data('id'))

            track.$el = $track
            $track.data('track', track)

        if showFirst
            @root().trigger('current:set', tracks[0])


    # Listeners #
    setCurrent: (track) ->
        track?.$el.addClass('active')
            .siblings('.active').removeClass('active')

    showPlaylist: (playlist) ->
        @tracks.add(playlist.tracks)
        @showTracks(@tracks.shuffle(), true)

    shuffleTracks: ->
        @showTracks(@tracks.shuffle())


    # Events #
    clickTrack: (e) ->
        track = $(e.currentTarget).data('track')
        @root().trigger('current:set', track)

    clickDelete: (e) ->
        e.preventDefault()
        e.stopPropagation()

        $track = $(e.currentTarget).parents('.track')

        # If the current track is deleted, play the next one
        if $track.hasClass('active')
            track = $track.next().data('track')
            @root().trigger('current:set', track)

        $track.remove()

module.exports = Tracks