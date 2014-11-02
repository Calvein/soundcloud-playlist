View = require('bamjs/view')

tmpl = require('./index.jade')


class Waveform extends View
    namespace: 'waveform'

    events:
        'click': 'click'

    gradientColor: '#bada55'

    initialize: (options) ->
        @$el.html(tmpl(
            gradientFrom: @gradientColor
            gradientTo: d3.rgb(@gradientColor).darker(.5).toString()
        ))

        @setupElements()
        @setupChart()

        @draw(@model.get('waveform'))

    createRect: (parent, type) ->
        rect = parent.append('rect')
            .attr('height', '100%')
            .attr('class', 'rect-' + type)

        # Some are already full
        if type in ['background', 'overlay']
            rect.attr('width', '100%')

        return rect

    setupElements: ->
        @svg = d3.select(@$el.find('svg').get(0))

        clipPathId = 'area-' + @model.id
        @groups =
            # The area is in a clippath
            clipPath: @svg.append('clipPath').attr('id', clipPathId)
            # Then we have 4 <rect>s
            rects: @svg.append('g')
                .attr('class', 'rects')
                .attr('clip-path', "url(##{clipPathId})")
            overlay: @createRect(@svg, 'overlay')

        @rects =
            # Background
            background: @createRect(@groups.rects, 'background')
            # Buffered, can be n rectangle
            # because it's a collection of TimeRange
            buffered: @groups.rects.append('g').attr('class', 'buffered-rects')
            # Played
            played: @createRect(@groups.rects, 'played')

    setupChart: ->
        # The width is variable
        @height = @$el.height()
        middle = @height / 2

        @trackScale = d3.scale.linear()
            .domain([0, @model.get('duration')])
            .range([0, 100])
        @x = d3.scale.linear()
        # Simple waveform from an area
        @y = d3.scale.linear()
            .range([0, @height / 2])

        @area = d3.svg.area()
            .x((d, i)  => @x(i))
            .y0((d, i) => @y(1 - d))
            .y1((d, i) => @y(1 + d))

    resize: ->
        @width = @$el.width()

        @x.range([0, @width])

    draw: (data) ->
        @resize()
        @x.domain([0, data.length - 1])

        @groups.clipPath.append('path')
            .datum(data)
            .attr('d', @area)

    drawPlayed: (time) ->
        @rects.played.attr('width', @trackScale(time) + '%')

    drawBuffered: (from, to, last) ->
        if not @buffered or last > @buffered.attr('data-i')
            @buffered = @createRect(@rects.buffered, 'buffered')

        @buffered
            .attr('data-i', last)
            .attr('x',   @trackScale(from) + '%')
            .attr('width', @trackScale(to) + '%')


    # Events #
    click: (e) ->
        @root().trigger('tracks:set', @model)

        done = =>
            @root().$audio.off('canplaythrough')
            time = @trackScale.invert(e.offsetX / @width) / 10
            @root().trigger('audio:seek', time)
            @root().trigger('audio:play')

        # When it's ready or if it's ready (can be too fast)
        @root().$audio.one('canplaythrough', done)
        done() if @root().audio.readyState > 3


module.exports = Waveform