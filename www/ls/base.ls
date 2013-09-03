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

$ "<span id='mld'>miliard Kč</span>"
    ..appendTo $centerValueContainer

$ "<div id='centerText'></div>"
    ..css \width innerWidth
    ..css \height innerWidth
    ..css \top 0.5 * (height - innerWidth)
    ..css \left 0.5 * (width - innerWidth)
    ..append $centerText
    ..append $centerValueContainer
    ..appendTo $ "body"

partition = d3.layout.partition!
    ..size [2* Math.PI, radius*radius]
    ..value -> it.vydaje
arc = d3.svg.arc!
    ..startAngle -> it.x
    ..endAngle -> it.x + it.dx
    ..innerRadius -> Math.sqrt it.y
    ..outerRadius -> Math.sqrt it.y + it.dy
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
        ..on \mouseover ->
            $centerText.text it.nazev
            $centerValue.text parseValue it.vydaje
        ..style \fill-rule \evenodd

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


