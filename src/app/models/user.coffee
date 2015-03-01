API_KEY = '98b4474b8d6ab99941c1edc1441478cd'
# There is no backend so fuck it
API_SECRET = '6531a456239925b5e32792c5a1c6589d'
BASE_URL = 'http://ws.audioscrobbler.com/2.0/'

Model = require('bamjs').Model
store = require('store')
crypto = require('crypto')
qs = require('querystring')

msToS = (ms) -> Math.round(ms / 1e3)


class User extends Model

    constructor: (attrs={}, options) ->
        attrs = $.extend(true, {}, attrs, store.get('user'))
        super(attrs, options)
        @listenTo(@, 'change', -> @save())

    initialize: (attributes={}, options) ->
        { @app } = options

        # Already connected to lastfm
        return if @get('sk')

        # Is connecting to lastfm
        cbUrl = 'http://127.0.0.1:8080/'
        console.log "http://www.last.fm/api/auth/?api_key=#{API_KEY}&cb=#{cbUrl}"
        { token } = qs.parse(location.search.slice(1))
        return unless token

        @set('token', token)

        params =
            method: 'auth.getSession'
            token: token
            api_key: API_KEY
        @getLastFmQuery(params).done((res) =>
            @set('name', res.session.name)
            @set('sk', res.session.key)
        )

    nowPlaying: (track) ->
        params =
            method: 'track.updateNowPlaying'
            artist: track.get('user').username
            track: track.get('title')
            duration: msToS(track.get('duration'))
            api_key: API_KEY
            sk: @get('sk')

        @getLastFmQuery(params)

    scrobble: (track) ->
        params =
            method: 'track.scrobble'
            artist: track.get('user').username
            track: track.get('title')
            timestamp: msToS(track.get('startPlaying'))
            duration: msToS(track.get('duration'))
            api_key: API_KEY
            sk: @get('sk')

        @getLastFmQuery(params).done((res) =>
            console.log res
        )

    getLastFmQuery: (params) ->
        params.api_sig = @createSignature(params)
        params.format = 'json'
        return $.ajax(
            url: BASE_URL
            data: params
            type: 'POST'
        )

    createSignature: (params) ->
        params = Object.keys(params).sort().map((key) ->
            return key + params[key]
        ).join('')

        return crypto.createHash('md5')
            .update(params + API_SECRET)
            .digest('hex')

    sync: (method, model, options) ->
        store.set('user', model.toJSON())
        @trigger('sync')


module.exports = User