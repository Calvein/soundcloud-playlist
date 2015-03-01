API_KEY = '98b4474b8d6ab99941c1edc1441478cd'
# There is no backend so fuck it
API_SECRET = '6531a456239925b5e32792c5a1c6589d'
BASE_URL = 'http://ws.audioscrobbler.com/2.0/'

View = require('bamjs/view')
crypto = require('crypto')
qs = require('querystring')

tmpl = require('./index.jade')


msToS = (ms) -> Math.round(ms / 1e3)

getLastFmQuery = (params) ->
    params.api_sig = createSignature(params)
    params.format = 'json'
    return $.ajax(
        url: BASE_URL
        data: params
        type: 'POST'
    )

createParams = (params, joint = '', itemJoint = '') ->
    params = Object.keys(params).sort().map((key) ->
        return key + itemJoint + params[key]
    ).join(joint)

createSignature = (params) ->
    return crypto.createHash('md5')
        .update(createParams(params) + API_SECRET)
        .digest('hex')

class Lastfm extends View
    namespace: 'lastfm'

    # events:
    #     'click': 'click'
    #     'mousemove': 'mousemove'
    #     'mouseleave': 'mouseleave'

    initialize: (options) ->
        # Is connecting to lastfm
        { token } = qs.parse(location.search.slice(1))
        if token
            @renderConnecting(token)
        # Already connected to lastfm
        else if @model.get('sk')
            @render()
        # Not connected
        else
            @renderNotConnected()

    render: ->
        @$el.html(tmpl(
            user: @model
        ))

        # Listeners #
        @listenTo(@root(), 'lastfm:nowPlaying', @nowPlaying)
        @listenTo(@root(), 'lastfm:scrobble', @scrobble)

    renderConnecting: (token) ->
        @model.set('token', token)

        params =
            method: 'auth.getSession'
            token: token
            api_key: API_KEY
        getLastFmQuery(params).done((res) =>
            @model.set('name', res.session.name)
            @model.set('sk', res.session.key)
            @render()
        )

    renderNotConnected: ->
        # Create url to connect to last.fm
        params =
            api_key: API_KEY
            cb: location.origin
        connectUrl = 'http://www.last.fm/api/auth/?'
        connectUrl += createParams(params, '&', '=')

        @$el.html(tmpl(
            connectUrl: connectUrl
        ))


    # Listeners #
    nowPlaying: (track) ->
        params =
            method: 'track.updateNowPlaying'
            artist: track.get('user').username
            track: track.get('title')
            duration: msToS(track.get('duration'))
            api_key: API_KEY
            sk: @model.get('sk')

        getLastFmQuery(params)

    scrobble: (track) ->
        params =
            method: 'track.scrobble'
            artist: track.get('user').username
            track: track.get('title')
            timestamp: msToS(track.get('startPlaying'))
            duration: msToS(track.get('duration'))
            api_key: API_KEY
            sk: @model.get('sk')

        getLastFmQuery(params).done((res) =>
            console.log res
        )


module.exports = Lastfm