API_KEY = '98b4474b8d6ab99941c1edc1441478cd'

View = require('bamjs/view')
qs = require('querystring')
{ msToS, getLastFmQuery, createParams } = require('../../modules/lastfm')

tmpl = require('./index.jade')


class Lastfm extends View
    namespace: 'lastfm'

    events:
        'click [data-dropdown]': 'clickDropdown'
        'change [data-private]': 'changePrivate'
        'click [data-disconnect]': 'clickDisconnect'

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

        # Store elements
        @$dropdownTrigger = @$('[data-dropdown]')
        @$dropdown = @$('.dropdown')

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
            cb: location.href
        connectUrl = 'http://www.last.fm/api/auth/?'
        connectUrl += createParams(params, '&', '=')

        @$el.html(tmpl(
            connectUrl: connectUrl
        ))


    # Listeners #
    nowPlaying: (track) ->
        return if @isPrivate
        params =
            method: 'track.updateNowPlaying'
            artist: track.get('user').username
            track: track.get('title')
            duration: msToS(track.get('duration'))
            api_key: API_KEY
            sk: @model.get('sk')

        getLastFmQuery(params)

    scrobble: (track) ->
        return if @isPrivate
        params =
            method: 'track.scrobble'
            artist: track.get('user').username
            track: track.get('title')
            timestamp: msToS(track.get('startPlaying'))
            duration: msToS(track.get('duration'))
            api_key: API_KEY
            sk: @model.get('sk')

        getLastFmQuery(params)

    openDropdown: ->
        @$dropdown.addClass('open')
        $(document).on('click.dropdown', (e) =>
            el = e.target
            unless el in [@$dropdownTrigger.get(0), @$dropdown.get(0)] or
                   @$dropdown.get(0).contains(el)
                @closeDropdown()
        )

    closeDropdown: ->
        @$dropdown.removeClass('open')

    # Events #
    clickDropdown: (e) ->
        e.preventDefault()
        if @$dropdown.hasClass('open')
            @closeDropdown()
        else
            @openDropdown()

    changePrivate: ->
        @isPrivate = !@isPrivate

    clickDisconnect: (e) ->
        e.preventDefault()
        @model.set('sk', null)
        @renderNotConnected()


module.exports = Lastfm