Collection = require('bamjs/collection')
Track = require('./track')


class Tracks extends Collection
    model: Track

    parse: (data) ->
        # Add the waveform data to each track
        done = 0
        data.forEach((d) =>
            $.ajax(
                url: 'http://www.waveformjs.org/w'
                dataType: 'jsonp'
                data: url: d.waveform_url
            ).done((waveform) =>
                @get(d.id).attributes.waveform = waveform
                if ++done is data.length
                    @trigger('parse:done')
            )
        )

        return data

module.exports = Tracks