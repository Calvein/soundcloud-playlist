# Soundcloud ID
CLIENT_ID = '5247b2c9dddfe7afb755c75a6198999d'

class Api

    url: 'http://api.soundcloud.com/resolve.json'

    contructor: ->

    getData: (url, cb) ->
        uri = '?url=' + url
        uri += '&client_id=' + CLIENT_ID

        $('body').addClass('loading')
        return $.get(@url + uri).done((data) ->
            $('body').removeClass('loading')
            cb(data) if cb
        )

    getPlaylists: (url) ->
        return @getData(url)

    getPlaylist: (url) ->
        return @getData(url, (playlist) ->
            # For conveniency
            playlist.tracks.forEach((track) ->
                track.src = track.stream_url + '?client_id=' + CLIENT_ID
            )
        )

    # We need to add the client_id
    getTrackDownloadUrl: (url) ->
        return url + '?client_id=' + CLIENT_ID


api = new Api()
module.exports = api