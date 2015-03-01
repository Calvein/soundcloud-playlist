Model = require('bamjs/model')
api = require('../modules/api')
waveformData = require('../modules/waveform-data')


class Track extends Model

    idAttribute: 'id'
    defaults:
        currentTime: 0

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

    isDownloadable: -> @get('downloadable')

    getDownloadUrl: -> api.getTrackDownloadUrl(@)

    parseType: 'ajax'
    # Canvas would be better but SoundCloud waveform aren't CORS friendly
    # parseType: 'canvas'
    getWaveform: ->
        waveform = @get('waveform')
        if waveform
            dfd = $.Deferred().resolve(waveform)
        else
            # Add the waveform data to each track
            if @parseType is 'ajax'
                dfd = $.ajax(
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
            else if @parseType is 'canvas'
                dfd = waveformData(@get('waveform_url'))

            dfd.done((waveform) =>
                @set('waveform', waveform)
            )

        return dfd


module.exports = Track