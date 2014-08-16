# App public ID
ID = '5247b2c9dddfe7afb755c75a6198999d'

# jQuery
$ = (sel, parent = document) ->
    parent.querySelector(sel)

# Elements
form = $('form')
input = $('input')
list = $('ul')
controls = $('.controls')
prev = $('.prev')
play = $('.play')
title = $('.title')
next = $('.next')
audio = new Audio()
audio.controls = true
form.appendChild(audio)

currentTrack = null

# After the playlist is fetched
showTracks = (playlist) ->
    controls.removeAttribute('hidden')

    # Fisher-Yates shuffle
    n = playlist.tracks.length
    while n
        i = Math.random() * n-- | 0 # 0 ≤ i < n
        t = playlist.tracks[n]
        playlist.tracks[n] = playlist.tracks[i]
        playlist.tracks[i] = t

    # Show tracklist
    for track in playlist.tracks
        li = document.createElement('li')
        li.textContent = track.title
        li.__data__ = track
        list.appendChild(li)

    # Setup the first track
    currentTrack = list.firstChild
    list.firstChild.classList.add('active')
    title.textContent = currentTrack.__data__.title
    audio.src = currentTrack.__data__.src

# Events #
# Toggle play or pause
playPause = ->
    play.classList.toggle('pause')
    if play.classList.contains('pause')
        play.textContent =  '>'
        audio.pause()
    else
        play.textContent = '||'
        audio.play()
play.addEventListener('click', playPause)

goTo = (el, forcePlay) ->
    return unless el
    currentTrack.classList.remove('active')
    currentTrack = el
    currentTrack.classList.add('active')

    # Set new data
    data = currentTrack.__data__
    title.textContent = data.title
    # Is true when you change the src
    isPlaying = forcePlay or !audio.paused
    audio.src = data.src
    if isPlaying then audio.play()

# Play other song
list.addEventListener('click', (e) ->
    el = e.target
    return unless el.nodeName is 'LI'
    goTo(el)
)

# Prev/Next
prevTrack = ->
    goTo(currentTrack.previousSibling)
prev.addEventListener('click', prevTrack)

nextTrack = (e) ->
    goTo(currentTrack.nextSibling, e.type is 'ended')
next.addEventListener('click', nextTrack)
audio.addEventListener('ended', nextTrack)

# Keyboard events
document.addEventListener('keyup', (e) ->
    return if $(':focus')
    switch e.which
        when 32 then playPause()
        when 37 then prevTrack()
        when 39 then nextTrack()
)

# Submit playlist
form.addEventListener('submit', (e) ->
    e.preventDefault()

    # Build API URL
    uri = 'http://api.soundcloud.com/resolve.json'
    uri += '?url=' + input.value
    uri += '&client_id=' + ID

    xhr = new XMLHttpRequest()
    xhr.open('GET', uri, true)

    xhr.onreadystatechange = (e) ->
        if @readyState is 4
            throw new Error('Error: ' + @status) unless @status is 200
            try
                playlist = JSON.parse(@responseText)
            catch error
                throw error
            if playlist.kind isnt 'playlist'
                throw new Error('Has to be a playlist')

            # For conveniency
            playlist.tracks.forEach((song) ->
                song.src = song.stream_url + '?client_id=' + ID
            )

            showTracks(playlist)
    xhr.send()
)