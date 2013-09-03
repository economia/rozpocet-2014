lastKapitola = null
(err, rows) <~ d3.csv "../data/rozpocet-2014.csv"
    .row ->
        if it['číslo kapitoly']
            lastKapitola := that
        return do
            nazev: it.podkapitola
            vydaje: it['výdaje 2014'].replace /,/g '' |> parseInt _, 10
            kapitola: it['číslo kapitoly']
            parent: if lastKapitola isnt it['číslo kapitoly'] then lastKapitola else null
    .get
width = 900
height = 900
svg = d3.select \body .append \svg
    ..attr \width width
    ..attr \height height
force = d3.layout.force!
    ..charge -120
    ..linkDistance 30
    ..size [width, height]

force
    ..nodes rows
    ..start!
scale = d3.scale.linear!
    ..domain [0 1192407508965]
    ..range [0 50]
node = svg.selectAll \.node
    .data rows
    .enter!append \circle
        ..attr \class \node
        ..attr \r -> scale it.vydaje
        ..style \fill \red
        ..call force.drag


force.on \tick ->
    node
        ..attr \cx (.x)
        ..attr \cy (.y)
