return if not Modernizr.svg
$ '.fallback' .remove!
new Tooltip!watchElements!
lastKapitola = null
firstNode = null
(err, rows) <~ d3.csv "../data/rozpocet-2014.csv"
    .row ->
        node =
            nazev: it.podkapitola.split ':' .0
            vydaje: it['výdaje 2014'].replace /,/g '' |> parseInt _, 10
            kapitola: it['číslo kapitoly']
            children: []

        if it['číslo kapitoly'] and firstNode
            node.parent = firstNode
            firstNode.children.push node
        else
            node.parent = lastKapitola
            if lastKapitola
                lastKapitola.children.push node
        if it['číslo kapitoly']
            lastKapitola := node
        if not firstNode
            firstNode := node
        node
    .get

firstNode.children .= sort (a, b) -> a.vydaje - b.vydaje
width = $ window .width!
height = $ window .height!
width = Math.min width, height
height = Math.min width, height
radius = 0.5 * height
color = d3.scale.ordinal!
    ..range <[#A6CEE3 #1F78B4 #B2DF8A #33A02C #FB9A99 #E31A1C #FDBF6F #FF7F00 #CAB2D6 #6A3D9A]>



svg = d3.select \body .append \svg
    ..attr \width width
    ..attr \height height

mainGroup = svg.append \g
    ..attr \transform "translate(#{width/2}, #{height/2})"
innerWidth = 1.9 * Math.sqrt radius * radius / 3
$centerText = $ "<span id='content'>Návrh výdajů státního rozpočtu pro rok 2014<small>Najeďte myší nad výseč a&nbsp;prohlédněte si jednotlivé kapitoly</small></span>"
    ..css \top innerWidth / 2 - 130
    ..css \width innerWidth - 100
$centerValueContainer = $ "<span id='valueContainer'></span>"
    ..css \top innerWidth / 2 + 40
    ..css \width innerWidth
$centerValue = $ "<span id='value'></span>"
    ..html "<span>celkem</span>1192"
    ..appendTo $centerValueContainer
$body = $ "body"
$ "<span id='mld'>miliard Kč</span>"
    ..appendTo $centerValueContainer

$center = $ "<div id='centerText'></div>"
    ..css \width innerWidth
    ..css \height innerWidth
    ..css \top 0.5 * (height - innerWidth)
    ..css \left 0.5 * (width - innerWidth)
    ..append $centerText
    ..append $centerValueContainer
    ..appendTo $body

partition = d3.layout.partition!
    ..size [2* Math.PI, radius*radius]
    ..value -> it.vydaje
arc = d3.svg.arc!
    ..startAngle -> (it.x + Math.PI)
    ..endAngle -> (it.x + it.dx + Math.PI)
    ..innerRadius -> Math.sqrt it.y
    ..outerRadius -> Math.sqrt it.y + it.dy
parseValue = ->
    val = it / 1e9
    exp = if val < 1
        1e2
    else if val < 10
        1e1
    else
        1
    val *= exp
    val = Math.round val
    val /= exp
    val .= toString!
    val .= replace '.' ','
path = mainGroup.datum firstNode .selectAll \path
    .data partition.nodes
    .enter!append \path
        ..attr \d arc
        ..style \stroke \#fff
        ..style \fill ->
            return \white if not it.parent
            colorParent = if it.parent and it.parent isnt firstNode
                it.parent.nazev
            else
                it.nazev
            color colorParent
        ..attr \data-tooltip ->
            if it isnt firstNode
                escape "#{it.nazev}: <strong>#{parseValue it.vydaje}</strong> miliard Kč"
            else
                ""
        ..on \mouseover ->
            $centerText.text it.nazev
            $centerValue.text parseValue it.vydaje
        ..on \click -> zoomTo it
        ..style \fill-rule \evenodd



zoomedNode = null
zoomTo = (arc) ->
    return killZoom! if arc in [firstNode, zoomedNode]
    zoomedNode := arc
    $body.addClass \zoomed
    setTimeout do
        -> $center.addClass \disabled
        800
    zoomLevel = Math.max do
        Math.PI / arc.dx / 2
        1
    zoomLevel = Math.min zoomLevel, 10
    angle = arc.x + 0.5 * arc.dx + Math.PI
    radius = if arc.parent is firstNode
        Math.sqrt arc.y + 0.8 * arc.dy
    else
        Math.sqrt arc.y
    ringCenterX = width / 2
    ringCenterY = height / 2
    arcCenterDX = radius * Math.sin angle
    arcCenterDY = (-1) * radius * Math.cos angle
    translationX = ringCenterX - arcCenterDX * zoomLevel
    translationY = ringCenterY - arcCenterDY * zoomLevel
    mainGroup
        ..transition!
            ..duration 800
            ..attr \transform "translate(#translationX, #translationY) scale(#zoomLevel)"

killZoom = ->
    zoomedNode := null
    mainGroup
        ..transition!
            ..duration 800
            ..attr \transform "translate(#{width/2}, #{height/2})"
    $center.removeClass \disabled
    <~ setTimeout _, 700
    $body.removeClass \zoomed
