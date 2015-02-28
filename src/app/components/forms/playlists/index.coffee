View = require('bamjs/view')
api = require('../../../modules/api')

tmpl = require('./index.jade')


class PlaylistForm extends View
    namespace: 'playlist-form'

    events:
        'submit': 'submit'
        'click [data-link=delete]': 'clickDelete'

    initialize: ->
        url = localStorage.getItem('url')
        unless url
            url = 'https://soundcloud.com/calvein/sets/mixtapes'
        @$el.html(tmpl(
            url: url
        ))

        # Listeners #
        @listenTo(@root(), 'playlist:get', @setPlaylist)
        @setPlaylist(url)

    setPlaylist: (url) ->
        localStorage.setItem('url', url)
        @getData(url)

    getPlaylist: (url) ->
        api.getPlaylist(url).done((playlist) =>
            @root().trigger('playlist:new', playlist)
        )

    getPlaylists: (url) ->
        api.getPlaylists(url).done((playlists) =>
            for playlist in playlists
                if confirm("Add playlist «#{playlist.title}» ?")
                    @root().trigger('playlist:new', playlist)
        )

    getData: (url) ->
        # Remove end slash
        url = url.replace(/\/$/, '')

        [user, set, playlist] = url
            .replace(/http(s*):\/\/soundcloud.com\//, '')
            .split('/')

        # Get the specified playlist
        if playlist
            return @getPlaylist(url)

        # If only the user is set, we fetch the playlists
        unless set or set isnt 'sets'
            url += '/sets'

        return @getPlaylists(url)


    # Events #
    submit: (e) ->
        e.preventDefault()
        url = @$('input').val()
        @setPlaylist(url)

    clickDelete: (e) ->
        @root().trigger('tracks:reset')

module.exports = PlaylistForm