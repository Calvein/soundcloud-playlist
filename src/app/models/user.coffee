Model = require('bamjs').Model
store = require('store')


class User extends Model

    constructor: (attrs = {}, options) ->
        attrs = $.extend(true, {}, attrs, store.get('user'))
        attrs.url ?= 'https://soundcloud.com/calvein/sets/mixtapes'
        super(attrs, options)
        @listenTo(@, 'change', -> @save())

    sync: (method, model, options) ->
        store.set('user', model.toJSON())
        @trigger('sync')


module.exports = User