View = require('bamjs/view')
Playlists = require('./playlists')
Filter = require('./filter')

tmpl = require('./index.jade')


class Forms extends View
    namespace: 'forms'

    initialize: ->
        @$el.html(tmpl())

        @playlistsForm = new Playlists(
            el: @$('.playlists-form')
            parent: @
        )

        @filterForm = new Filter(
            el: @$('.filter-form')
            parent: @
        )



module.exports = Forms