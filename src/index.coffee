Backbone = require('bamjs').Backbone
Backbone.$ = $

App = require('./app')

window.app = new App(
    el: document.body
)