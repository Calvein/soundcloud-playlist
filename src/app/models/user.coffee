Model = require('bamjs').Model
store = require('store')
soundcloudUrlData = require('../modules/soundcloud-url-data')

class User extends Model

    constructor: (attrs = {}, options) ->
        attrs = $.extend(true, {}, attrs, store.get('user-data'))

        # Get the user/playlist in the url first
        url = location.hash.slice(1)
        if url
            { user, playlist } = soundcloudUrlData.getData(url)
        # Else, get it from localstorage
        if not user
            user = attrs.user
            playlist = attrs.playlist
        # Otherwise get the best url possible
        if not user
            user = 'calvein'
            playlist = 'mixtapes'

        attrs.user = user
        attrs.playlist = playlist
        super(attrs, options)
        @listenTo(@, 'change', -> @save())

    sync: (method, model, options) ->
        store.set('user-data', model.toJSON())
        @trigger('sync')

    getUser: -> @get('user')
    getPlaylist: -> @get('playlist')

    setUrl: (url) ->
        { user, playlist } = soundcloudUrlData.getData(url)
        @set('user', user)
        @set('playlist', playlist)
        @save()


module.exports = User