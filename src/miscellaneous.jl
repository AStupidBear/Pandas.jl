export SparseDataFrame, pdhcat, pdvcat, noconsolidation

SparseDataFrame(args...; kws...) = DataFrame(pandas_raw.SparseDataFrame(args...; kws...))

function merge(df1::DataFrame, df2::DataFrame; kws...)
    if occursin("Sparse", string(df1.pyo.__class__))
        df1, df2 = df2, df1
    end
    pandas_wrap(pycall(df1.pyo.merge, PyObject, df2.pyo; kws...))
end

Base.setindex!(df::DataFrame, v::AbstractArray, col::Union{Symbol, String}) = setindex!(df, v, [col])

function Base.setindex!(df::DataFrame, v::AbstractArray, cols)
    if isempty(df)
        df_merge = DataFrame(v, copy = false, columns = cols)
        df.pyo = df_merge.pyo
    elseif size(v, 1) == length(df) && !issubset(cols, columns(df))
        df_set = DataFrame(v, copy = false, columns = cols, index = index(df))
        df_merge = merge(df, df_set, left_index = true, right_index = true, copy = false)
        df.pyo = df_merge.pyo
    else
        df[cols] = DataFrame(v)
    end
    return df
end

function pdhcat(dfs...)
    dfs = filter(!isempty, collect(dfs))
    df = dfs[1]
    for dfn in dfs[2:end]
        df = merge(df, dfn, left_index = true, right_index = true, copy = false)
    end
    return df
end

pdvcat(xs...) = concat([xs...], axis = 0, ignore_index = true)

Base.ndims(x::Iloc) = length(size(x))
Base.view(x::Iloc, is...) = getindex(x, is...)

function noconsolidation()
    py"""
    def _consolidate_inplace(self):
        pass

    def _consolidate(self):
        return self.blocks

    from pandas.core.internals import BlockManager
    BlockManager._consolidate_inplace = _consolidate_inplace
    BlockManager._consolidate = _consolidate
    """
end

ispydate(x) = false
ispystr(x) = false

ispydate(x::Series) = occursin("datetime", string(x.pyo.dtype.type))
ispystr(x::Series) = isa(iloc(x)[1], String)
