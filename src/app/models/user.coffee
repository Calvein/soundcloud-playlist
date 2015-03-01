Model = require('bamjs').Model
store = require('store')


class User extends Model

    constructor: (attrs={}, options) ->
        attrs = $.extend(true, {}, attrs, store.get('user'))
        super(attrs, options)
        @listenTo(@, 'change', -> @save())

    initialize: (attributes={}, options) ->
        { @app } = options

    sync: (method, model, options) ->
        store.set('user', model.toJSON())
        @trigger('sync')


module.exports = User