'use strict'

const app = require('app')
const BrowserWindow = require('browser-window')
const globalShortcut = require('global-shortcut')

// Report crashes to our server.
require('crash-reporter').start()

// Quit when all windows are closed.
app.on('window-all-closed', function() {
    // On OS X it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') {
        app.quit()
    }
})

let mainWindow = null
app.on('ready', function() {
    // Create the browser window.
    mainWindow = new BrowserWindow({
        width: 1200
      , height: 800
    })

    // Load the index.html of the app.
    mainWindow.loadUrl(`file://${__dirname}/index.html`)

    globalShortcut.register('MediaPlayPause', function() {
        ipc.send('togglePlay')
    })
    globalShortcut.register('MediaStop', function() {
        ipc.send('stop')
    })
    globalShortcut.register('MediaNextTrack', function() {
        ipc.send('nextTrack')
    })
    globalShortcut.register('MediaPreviousTrack', function() {
        ipc.send('previousTrack')
    })

    mainWindow.on('closed', function() {
        mainWindow = null
    })
})