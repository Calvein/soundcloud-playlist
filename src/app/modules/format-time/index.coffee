module.exports = (ms, format) ->
    s = Math.round(ms / 1e3)
    switch format
        when 's' then return s
        when 'mm:ss'
            minutes = Math.floor(s / 60)
            seconds = s % 60
            if seconds < 10 then seconds = '0' + seconds
            return minutes + ':' + seconds
        else return ms