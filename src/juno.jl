using Atom, BrowseTables

export JTable

struct JTable
    data
end

JTable(x::AbstractArray) = JTable(DataFrame(x))

function Base.show(io::IO, ::MIME"application/prs.juno.plotpane+html", tbl::JTable)
    df = round(tbl.data, 3)
    html = tempname() * ".html"
    write_html_table(html, df)
    print(io, read(html, String))
end

function Base.open(tbl::JTable)
    df = round(tbl.data, 3)
    csv = joinpath(homedir(), ".cache/jtable.csv")
    to_csv(df, csv)
    Atom.msg("openFile", csv)
end