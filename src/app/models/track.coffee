Model = require('bamjs/model')


class Track extends Model

    getImage: ->
        url = @get('artwork_url')
        unless url
            url = @get('user').avatar_url
        return url

    getUsername: -> @get('user').username

module.exports = Track