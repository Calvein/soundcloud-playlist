View = require('bamjs/view')
api = require('../../modules/api')

tmpl = require('./index.jade')


class Form extends View
    namespace: 'form'

    events:
        'submit': 'submit'

    initialize: ->
        # TODO get in localstorage
        url = 'https://soundcloud.com/calvein/sets/songs'
        @$el.html(tmpl(
            url: url
        ))

        # Listeners #
        @listenTo(@root(), 'playlist:get', @submit)

    getPlaylist: (url) ->
        $('body').addClass('loading')
        api.getPlaylist(url).done((playlist) =>
            @root().trigger('playlist:new', playlist)
            $('body').removeClass('loading')
        )


    # Events #
    submit: (e) ->
        e?.preventDefault()
        @getPlaylist(@$('input').val())



module.exports = Form