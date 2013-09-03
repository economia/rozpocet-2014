lastKapitola = null
firstNode = null
(err, rows) <~ d3.csv "../data/rozpocet-2014.csv"
    .row ->
        node =
            nazev: it.podkapitola
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
    ..range [-50 -300]
scale = d3.scale.linear!
    ..domain [0 1192407508965]
    ..range [0 5000]
force = d3.layout.force!
    ..charge -> chargeScale it.vydaje
    ..linkDistance ->
        r1 = Math.sqrt scale it.source.vydaje
        r2 = Math.sqrt scale it.target.vydaje
        (r1 + r2)
    ..size [width, height]

force
    ..nodes rows
    ..links links
    ..start!
link = svg.selectAll \.link
    .data links
    .enter!append \line
        ..attr \class \link
        ..style \stroke-width \1px
        ..style \stroke \black
node = svg.selectAll \.node
    .data rows
    .enter!append \circle
        ..attr \class \node
        ..attr \r -> Math.sqrt scale it.vydaje
        ..style \fill \red
        ..call force.drag


force.on \tick ->
    node
        ..attr \cx (.x)
        ..attr \cy (.y)
    link
        ..attr \x1 (.source.x)
        ..attr \y1 (.source.y)
        ..attr \x2 (.target.x)
        ..attr \y2 (.target.y)
