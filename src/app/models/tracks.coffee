Collection = require('bamjs/collection')
Track = require('./track')

class Tracks extends Collection
    model: Track

    getVisibleTracks: -> @filter((track) -> track.isVisible())


module.exports = Tracks