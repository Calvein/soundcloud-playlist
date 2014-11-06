module.exports = (src) ->
    dfd = $.Deferred()

    imgWidth = 1800
    imgHeight = 280 / 2
    img = document.createElement('img')

    canvas = document.createElement('canvas')
    canvas.width = imgWidth
    canvas.height = imgHeight
    ctx = canvas.getContext('2d')

    img.addEventListener('load', ->
        ctx.drawImage(img, 0, 0)
        pixels = ctx.getImageData(0, 0, imgWidth, imgHeight).data

        len = pixels.length
        i = 0
        data = []
        alphaPixels = 0
        for i in [0..pixels.length] by 4
            if pixels[i] > 0
                alphaPixels++

            if i and i / 4 % imgHeight is 0
                data.push(alphaPixels / imgHeight)
                alphaPixels = 0
            break if i++ > len

        dfd.resolve(data)
    )
    # To test
    # img.crossOrigin = 'anonymous'
    # img.src = 'http://i.imgur.com/1xweuKj.png'
    img.src = 'https://w1.sndcdn.com/G5d1wBmLJ2Kw_m.png'

    return dfd