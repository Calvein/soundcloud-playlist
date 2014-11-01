# Soundcloud ID
CLIENT_ID = '5247b2c9dddfe7afb755c75a6198999d'

class Api

    url: 'http://api.soundcloud.com/resolve.json'

    contructor: ->

    getPlaylist: (url) ->
        uri = @url
        uri += '?url=' + url
        uri += '&client_id=' + CLIENT_ID

        return $.get(uri).done((playlist) ->
            # For conveniency
            playlist.tracks.forEach((track) ->
                track.src = track.stream_url + '?client_id=' + CLIENT_ID
            )
        )

    getTrackDownloadUrl: (track) ->
        # We need to add the client_id
        url = track.get('download_url')
        url += '?client_id=' + CLIENT_ID

        return url

api = new Api()
module.exports = api