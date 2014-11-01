Model = require('bamjs/model')
api = require('../modules/api')


class Track extends Model

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


module.exports = Track