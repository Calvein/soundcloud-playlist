var gulp = require('gulp')
var gutil = require('gulp-util')
var coffee = require('gulp-coffee')
var jade = require('gulp-jade')
var stylus = require('gulp-stylus')

var http = require('http')
var connect = require('connect')
var serveStatic = require('serve-static')
var lr = require('tiny-lr')


var env = gutil.env.prod ? 'prod' : 'dev'

/* Files */
var coffescriptFile = './app/*.coffee'
var jadeFile = './app/*.jade'
var stylusFile = './app/*.styl'

/* Compile functions */
var coffescriptCompile = function(cb) {
    gulp.src(coffescriptFile)
        .pipe(coffee({ bare: true }))
        .pipe(gulp.dest('./'))
        .on('end', cb || function() {})
}

var jadeCompile = function(cb) {
    var locals = {
        env: env
    }

    gulp.src(jadeFile)
        .pipe(jade({
            locals: locals
        }))
        .pipe(gulp.dest('./'))
        .on('end', cb || function() {})
}

var stylusCompile = function(cb) {
    gulp.src(stylusFile)
        .pipe(stylus())
        .pipe(gulp.dest('./'))
        .on('end', cb || function() {})
}

var triggerLr = function (type) {
    var query = ''
    if (type === 'all') query = 'files=index.html'
    if (type === 'css') query = 'files=index.css'

    http.get('http://127.0.0.1:35729/changed?' + query)
}

var build = function() {
    coffescriptCompile()
    jadeCompile()
    stylusCompile()
}

function serve() {
    var app = connect()
        .use(serveStatic('./'))

    http.createServer(app)
        .listen(8080, function(err) {
            if (err) return handleError(err, cb)
            gutil.log('Serving app on port', gutil.colors.yellow(8080))
        })
}

var watch = function() {
    // Watch Jade
    gulp.watch(coffescriptFile, function() {
        coffescriptCompile(function() {
            triggerLr('all')
        })
    })

    // Watch Jade
    gulp.watch(jadeFile, function() {
        coffescriptCompile(function() {
            triggerLr('all')
        })
    })

    // Watch Stylus
    gulp.watch(stylusFile, function() {
        stylusCompile(function() {
            triggerLr('css')
        })
    })

    lr().listen(35729)
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