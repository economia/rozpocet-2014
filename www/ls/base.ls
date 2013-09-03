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
