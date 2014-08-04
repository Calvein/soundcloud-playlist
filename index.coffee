id = '5247b2c9dddfe7afb755c75a6198999d'

input = document.querySelector('input')
form = document.querySelector('form')
audio = new Audio()

form.addEventListener('submit', (e) ->
    e.preventDefault()

    uri = 'http://api.soundcloud.com/resolve.json'
    uri += "?url=#{input.value}"
    uri += "&client_id=#{id}"

    songs = []

    playlist = null
    xhr = new XMLHttpRequest()
    xhr.open('GET', uri, true)

    xhr.onreadystatechange = (e) ->
        if @readyState is 4 and @status is 200
            playlist = JSON.parse(@responseText)
            if playlist.kind isnt 'playlist'
                throw new Error('Has to be a playlist')

            playlist.tracks.forEach((song) ->
                song.src = song.stream_url + '?client_id=' + id
            )
            # For conveniency
            tracks = playlist.tracks


            track = tracks[Math.floor(Math.random() * tracks.length)]
            console.log track.title
            audio.src = track.src
            audio.play()

    xhr.send()
)
