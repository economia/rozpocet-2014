lastKapitola = null
firstNode = null
(err, rows) <~ d3.csv "../data/rozpocet-2014.csv"
    .row ->
        node =
            nazev: it.podkapitola.split '(' .0
            vydaje: it['výdaje 2014'].replace /,/g '' |> parseInt _, 10
            kapitola: it['číslo kapitoly']
            parent: if it['číslo kapitoly'] then firstNode else lastKapitola
        if it['číslo kapitoly']
            lastKapitola := node
        if not firstNode
            firstNode := node
        node
    .get
width = 1900
height = 1050
links = []
rows.forEach (row) ->
    if row.parent
        links.push do
            source: row
            target: row.parent

svg = d3.select \body .append \svg
    ..attr \width width
    ..attr \height height
chargeScale = d3.scale.linear!
    ..domain [0 1192407508965]
    ..range [-50 -4000]
scale = d3.scale.sqrt!
    ..domain [0 1192407508965]
    ..range [0 80]
force = d3.layout.force!
    ..charge -> chargeScale it.vydaje
    ..linkDistance ->
        r1 = scale it.source.vydaje
        r2 = scale it.target.vydaje
        (r1 + r2)
    ..size [width, height]

force
    ..nodes rows
    ..links links
    ..alpha 0.9
    ..start!
link = svg.selectAll \.link
    .data links
    .enter!append \line
        ..attr \class \link
        ..style \stroke-width \1px
        ..style \stroke \black
nodeGroup = svg.selectAll \.nodeGroup
    .data rows
    .enter!append \g
        ..attr \transform "translate(5, 5)"
        ..call force.drag
        ..append \circle
            ..attr \class \node
            ..attr \r -> scale it.vydaje
            ..style \fill \red
        ..append \text
            ..text (.nazev)


force.on \tick ->
    nodeGroup
        ..attr \transform ({x, y})-> "translate(#x, #y)"
    link
        ..attr \x1 (.source.x)
        ..attr \y1 (.source.y)
        ..attr \x2 (.target.x)
        ..attr \y2 (.target.y)
