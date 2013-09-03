new Tooltip!watchElements!
lastKapitola = null
firstNode = null
(err, rows) <~ d3.csv "../data/rozpocet-2014.csv"
    .row ->
        node =
            nazev: it.podkapitola.split '(' .0
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
radius = 0.5 * Math.min width, height
color = d3.scale.ordinal!
    ..range <[#A6CEE3 #1F78B4 #B2DF8A #33A02C #FB9A99 #E31A1C #FDBF6F #FF7F00 #CAB2D6]>

svg = d3.select \body .append \svg
    ..attr \width width
    ..attr \height height

mainGroup = svg.append \g
    ..attr \transform "translate(#{width/2}, #{height/2})"
partition = d3.layout.partition!
    ..sort null
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
            colorParent = if it.parent and it.parent isnt firstNode
                it.parent.nazev
            else
                it.nazev
            color colorParent
        ..attr \data-tooltip -> it.nazev
        ..style \fill-rule \evenodd
