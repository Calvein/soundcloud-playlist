Model = require('bamjs/model')
api = require('../modules/api')
waveformData = require('../modules/waveform-data')
formatTime = require('../modules/format-time')

class Track extends Model

    idAttribute: 'id'
    defaults:
        currentTime: 0
        hidden: false

    getTitle: -> @get('title')

    getCurrentTime: -> @get('currentTime')

    getSrc: -> @get('src')

    getDuration: (format) -> formatTime(@get('duration'), format)

    getStartPlaying: (format) -> formatTime(@get('startPlaying'), format)

    getImage: ->
        url = @get('artwork_url')
        unless url
            url = @get('user').avatar_url
        return url

    getUrl: (type='track') ->
        switch type
            when 'track' then @get('permalink_url')
            when 'user' then @get('user').permalink_url

    getUsername: -> @get('user').username

    isVisible: -> !@get('hidden')

    isDownloadable: -> @get('downloadable')

    getDownloadUrl: -> api.getTrackDownloadUrl(@get('download_url'))

    getNextVisibleTrack: ->
        track = @
        loop
            track = track.next()
            break if !track or track.isVisible()

        return track

    getPreviousVisibleTrack: ->
        track = @
        loop
            track = track.prev()
            break if !track or track.isVisible()

        return track

    parseType: 'ajax'
    # Canvas would be better but SoundCloud waveform aren't CORS friendly
    # parseType: 'canvas'
    getWaveform: ->
        dfd = $.Deferred()
        waveform = @get('waveform')
        if waveform
            return dfd.resolve(waveform)

        # Add the waveform data to each track
        if @parseType is 'ajax'
            $.ajax(
                url: 'http://www.waveformjs.org/w'
                dataType: 'jsonp'
                data: url: @get('waveform_url')
            ).fail(=>
                # Create fake waveform to still be able to click on it
                # when the service is down
                waveLength = 200
                scale = d3.scale.linear()
                    .interpolate(-> d3.ease('sin-in-out'))
                    .range([0, 1])
                    .domain([0, waveLength])
                waveform = [0...1800].map((i) ->
                    i %= waveLength
                    i = if i > waveLength / 2 then waveLength - i else i
                    return scale(i * 2)
                )

                dfd.resolve(waveform)
            )
            .done((waveform) =>
                @set('waveform', waveform)
                dfd.resolve(waveform)
            )
        else if @parseType is 'canvas'
            dfd = waveformData(@get('waveform_url'))

        return dfd


module.exports = Track