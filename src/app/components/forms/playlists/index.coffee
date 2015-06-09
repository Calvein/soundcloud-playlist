View = require('bamjs/view')
api = require('../../../modules/api')
soundcloudUrlData = require('../../../modules/soundcloud-url-data')

tmpl = require('./index.jade')

class PlaylistForm extends View
    namespace: 'playlist-form'

    events:
        'submit': 'submit'
        'click [data-link=delete]': 'clickDelete'

    initialize: ->
        user = @root().user.getUser()
        playlist = @root().user.getPlaylist()

        url = user
        if playlist
            url += "/#{playlist}"

        @$el.html(tmpl(
            url: url
        ))

        @setPlaylist(url)

    setPlaylist: (url) ->
        @root().user.setUrl(url)
        @getData(url)

    getPlaylist: (url) ->
        api.getPlaylist(url).done((playlist) =>
            @root().trigger('playlist:new', playlist)
        ).fail((jqXHR, textStatus, errorThrown) =>
            @showRequestError(jqXHR, textStatus, errorThrown, 'playlist')
        )

    getPlaylists: (url) ->
        api.getPlaylists(url).then((playlists, textStatus, jqXHR) =>
            if playlists.length is 0
                return new $.Deferred()
                    .reject(null, null, 'No playlists')
                    .promise()

            for playlist in playlists
                if confirm("Add playlist «#{playlist.title}» ?")
                    @root().trigger('playlist:new', playlist)
        ).fail((jqXHR, textStatus, errorThrown) =>
            @showRequestError(jqXHR, textStatus, errorThrown, 'user')
        )

    showRequestError: (jqXHR, textStatus, errorThrown, type) ->
        alert("Error while getting #{type}: \"#{errorThrown}\"")
        console.error('Results of the fail request:')
        console.log('jqXHR', jqXHR)
        console.log('textStatus', textStatus)
        console.log('errorThrown', errorThrown)


    getData: (url) ->
        { user, playlist } = soundcloudUrlData.getData(url)
        url = soundcloudUrlData.getUrl(user, playlist)

        if playlist
            return @getPlaylist(url)
        return @getPlaylists(url)


    # Events #
    submit: (e) ->
        e.preventDefault()
        url = @$('input').val()
        @setPlaylist(url)

    clickDelete: (e) ->
        if confirm('Do you really want to remove all the tracks ?')
            @root().trigger('tracks:reset')


module.exports = PlaylistForm