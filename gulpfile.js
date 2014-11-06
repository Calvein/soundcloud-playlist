var gulp = require('gulp')
var gutil = require('gulp-util')
var duration = require('gulp-duration')
var source = require('vinyl-source-stream')
var http = require('http')
var connect = require('connect')
var serveStatic = require('serve-static')
var lr = require('tiny-lr')
var growl = require('growl')

// Script
var watchify = require('watchify')
var browserify = require('browserify')
var coffeeify = require('coffeeify')
var jadeify = require('browserify-jade').jade({ pretty: false })
// Template
var jade = require('gulp-jade')
// Style
var stylus = require('gulp-stylus')


var port = 8080
var portLr = 35729
var env = gutil.env.prod ? 'prod' : 'dev'
var handleError = function(err) {
    gutil.log(err)
    growl('Check your terminal.', { title: 'Gulp error' })
}

/* Files */
var coffeeFile = './src/index.coffee'
var jadeFile = './src/index.jade'
var stylusFile = './src/index.styl'
// For watch
var stylusFiles = [
    stylusFile
  , './src/app/components/**/*.styl'
]

/* Compile functions */
// Watchify bundle
var bundle = null
var scriptCompile = function(cb) {
    if (!bundle) {
        bundle = watchify(browserify(coffeeFile, {
            extensions: ['.coffee']
          , debug: env !== 'prod'
            // Required for watchify
          , cache: {}
          , packageCache: {}
          , fullPaths: true
        }))
        .transform(coffeeify)
        .transform(jadeify)
        .on('update', function() {
            scriptCompile(function() {
                triggerLr('all')
            })
        })
    }

    bundle.bundle()
        .on('error', handleError)
        .pipe(source('app.js'))
        .pipe(duration('Reloading app'))
        .pipe(gulp.dest('./'))
        .on('end', cb || function() {})
}

var templateCompile = function(cb) {
    var locals = {
        env: env
    }

    gulp.src(jadeFile)
        .pipe(jade({
            locals: locals
        }))
        .on('error', handleError)
        .pipe(duration('Reloading template'))
        .pipe(gulp.dest('./'))
        .on('end', cb || function() {})
}

var styleCompile = function(cb) {
    gulp.src(stylusFile)
        .pipe(stylus())
        .on('error', handleError)
        .pipe(duration('Reloading style'))
        .pipe(gulp.dest('./'))
        .on('end', cb || function() {})
}

var triggerLr = function (type) {
    var query = ''
    if (type === 'all') query = '?files=index.html'
    if (type === 'css') query = '?files=index.css'

    http.get('http://127.0.0.1:' + portLr + '/changed' + query)
}

/* Tasks functions */
var build = function() {
    scriptCompile()
    templateCompile()
    styleCompile()
}

var serve = function() {
    var app = connect()
        .use(serveStatic('./'))

    http.createServer(app)
        .listen(port, function(err) {
            gutil.log('Serving app on port', gutil.colors.yellow(port))
        })
}

var watch = function() {
    // Watch Jade
    gulp.watch(jadeFile, function() {
        templateCompile(function() {
            triggerLr('all')
        })
    })

    // Watch Stylus
    gulp.watch(stylusFiles, function() {
        styleCompile(function() {
            triggerLr('css')
        })
    })

    lr().listen(portLr, function(err) {
        gutil.log('Livereload on port', gutil.colors.yellow(portLr))
    })
}


/* Tasks */
gulp.task('build', function() {
    build()
})

gulp.task('serve', function() {
    watch()
    serve()
})

gulp.task('default', ['build', 'serve'])