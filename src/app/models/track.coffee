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
    # parseType: 'canvas'
    getWaveform: ->
        # Add the waveform data to each track
        if @parseType is 'ajax'
            dfd = $.ajax(
                url: 'http://www.waveformjs.org/w'
                dataType: 'jsonp'
                data: url: @get('waveform_url')
            )
        else if @parseType is 'canvas'
            dfd = waveformData(@get('waveform_url'))

        dfd.done((waveform) =>
            @set('waveform', waveform)
        )

        return dfd


module.exports = Track