using Atom, BrowseTables

export JTable

struct JTable
    data
end

JTable(x::AbstractArray) = JTable(DataFrame(x))

function Base.show(io::IO, ::MIME"application/prs.juno.plotpane+html", tbl::JTable)
    html = tempname() * ".html"
    csv = joinpath(homedir(), ".cache/jtable.csv")
    df = round(tbl.data, 3)
    write_html_table(html, df)
    to_csv(df, csv)
    Atom.msg("openFile", csv)
    print(io, read(html, String))
end