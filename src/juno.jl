using Random, Atom

export JTable

mutable struct JTable
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
    csv = joinpath(homedir(), ".cache", randstring() * ".csv")
    tbl.data.to_csv(csv, encoding = "gbk")
    finalizer(x -> rm(csv), tbl)
    Atom.msg("openFile", csv)
end