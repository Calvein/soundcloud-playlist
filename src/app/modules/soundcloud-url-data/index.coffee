SOUNDCLOUD_BASE_URL = 'https://soundcloud.com'
SOUNDCLOUD_BASE_REG = /^https?:\/\/soundcloud\.com\/(.*)/

getData = (url) ->
    if SOUNDCLOUD_BASE_REG.test(url)
        url = url.match(SOUNDCLOUD_BASE_REG)[1]

    [user, sets, playlist] = url.split('/')

    # When it's just user/playlist
    if sets isnt 'sets'
        playlist = sets

    return { user, playlist }

getUrl = (user, playlist) ->
    url = "#{SOUNDCLOUD_BASE_URL}/#{user}/sets"

    if playlist
        url += "/#{playlist}"

    return url


module.exports =
    getData: getData
    getUrl: getUrl