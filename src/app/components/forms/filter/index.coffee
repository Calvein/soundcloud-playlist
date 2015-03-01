View = require('bamjs/view')

tmpl = require('./index.jade')


class FilterForm extends View
    namespace: 'filter-form'

    events:
        'input input': 'input'
        'submit': 'submit'

    initialize: ->
        @$el.html(tmpl())


    # Events #
    input: (e) ->
        filter = @$('input').val()
        @root().trigger('playlist:filter', filter)

    submit: (e) ->
        e.preventDefault()


module.exports = FilterForm