Collection = require('bamjs/collection')
Track = require('./track')
waveformData = require('../modules/waveform-data')

class Tracks extends Collection
    model: Track

    parseType: 'ajax'
    # parseType: 'canvas'

    parse: (data) ->
        # Add the waveform data to each track
        done = 0
        data.forEach((d) =>
            if @parseType is 'ajax'
                dfd = $.ajax(
                    url: 'http://www.waveformjs.org/w'
                    dataType: 'jsonp'
                    data: url: d.waveform_url
                )
            else if @parseType is 'canvas'
                dfd = waveformData(d.waveform_url)

            dfd.done((waveform) =>
                console.timeEnd 'parse'
                @get(d.id).attributes.waveform = waveform
                if ++done is data.length
                    @trigger('parse:done')
            )
        )

        return data

module.exports = Tracks