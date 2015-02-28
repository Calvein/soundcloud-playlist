View = require('bamjs/view')

tmpl = require('./index.jade')


class Waveform extends View
    namespace: 'waveform'

    events:
        'click': 'click'
        'mousemove': 'mousemove'
        'mouseleave': 'mouseleave'

    initialize: (options) ->
        @undelegateEvents()
        @$el.html(tmpl())

        @setupElements()
        @setupChart()

        @model.getWaveform().done((waveform) =>
            @draw(waveform)
            @delegateEvents()
        )

    createRect: (parent, type) ->
        rect = parent.append('rect')
            .attr('height', '100%')
            .attr('class', 'rect-' + type)

        # Some are already full
        if type in ['background', 'overlay']
            rect.attr('width', '100%')
        else if type is 'hovered'
            rect.classed('hidden', true)

        return rect

    setupElements: ->
        @svg = d3.select(@$el.find('svg').get(0))

        clipPathId = 'area-' + @model.id
        @groups =
            # The area is in a clippath
            clipPath: @svg.append('clipPath').attr('id', clipPathId)
            # Then we have 5 <rect>s
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
            # Hovered
            hovered: @createRect(@groups.rects, 'hovered')

    setupChart: ->
        # The width is variable
        @height = @$el.height()
        middle = @height / 2

        @currentTime = 0
        @trackScale = d3.scale.linear()
            .domain([0, @model.get('duration')])
            .range([0, 100])
        # The data comes from the waveform and it's an array of 1800 values
        @x = d3.scale.linear()
            .domain([0, 1800])
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

        @groups.clipPath.append('path')
            .datum(data)
            .attr('d', @area)

        @$el.addClass('drawn')

    drawPlayed: (time) ->
        @currentTime = time
        @rects.played.attr('width', @trackScale(time) + '%')

    drawBuffered: (from, to, last) ->
        if not @buffered or last > @buffered.attr('data-i')
            @buffered = @createRect(@rects.buffered, 'buffered')

        @buffered
            .attr('data-i', last)
            .attr('x',   @trackScale(from) + '%')
            .attr('width', @trackScale(to) + '%')

    goTo: (x) ->
        time = @trackScale.invert(x / @width) / 10
        @root().trigger('audio:seek', time)
        @root().trigger('audio:play')


    # Events #
    click: (e) ->
        if @root().currentTrack is @model and @root().audio.readyState is 4
            @goTo(e.offsetX)
        else
            @root().trigger('tracks:set', @model)
            @root().$audio.one('canplaythrough', =>
                @goTo(e.offsetX)
            )

    mousemove: (e) ->
        hoverPct = e.offsetX / @width * 100
        playedPct = @trackScale(@currentTime)

        if hoverPct > playedPct
            x = playedPct
            pct = hoverPct - playedPct

        else
            pct = playedPct - hoverPct
            x = playedPct - pct

        @rects.hovered
            .classed('hidden', false)
            .attr('x', x + '%')
            .attr('width', pct + '%')

    mouseleave: (e) ->
        @rects.hovered.classed('hidden', true)


module.exports = Waveform