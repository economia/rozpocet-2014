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
width = 650
height = 650

svg = d3.select \body .append \svg
    ..attr \width width
    ..attr \height height
