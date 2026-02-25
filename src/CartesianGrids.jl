module CartesianGrids

using StaticArrays

export CartesianGrid, grid1d, meshsize, cell_spacing, cell_center, dimension, CartesianIndices, interior_indices

"""
    abstract type AbstractMesh{N,T}

An abstract mesh structure in dimension `N` with primite data of type `T`.
"""
abstract type AbstractMesh{N, T} end

struct CartesianGrid{N, T} <: AbstractMesh{N, T}
    lc::SVector{N, T}
    hc::SVector{N, T}
    n::NTuple{N, Int}
end

"""
    CartesianGrid(lc, hc, n)

Create a uniform cartesian grid with lower corner `lc`, upper corner `hc` and and `n` nodes
in each direction.
"""
function CartesianGrid(lc, hc, n)
    length(lc) == length(hc) == length(n) ||
        throw(ArgumentError("all arguments must have the same length"))
    N = length(lc)
    lc_ = SVector{N, eltype(lc)}(lc...)
    hc_ = SVector{N, eltype(hc)}(hc...)
    n = ntuple(i -> Int(n[i]), N)
    return CartesianGrid(promote(lc_, hc_)..., n)
end

"""
    grid1d(g::CartesianGrid, dim)

Return the 1D grid points along the specified dimension `dim` of the Cartesian grid `g`.
"""
grid1d(g::CartesianGrid{N}) where {N} = ntuple(i -> grid1d(g, i), N)
grid1d(g::CartesianGrid, dim) = g.n[dim] == 1 ? LinRange(g.lc[dim], g.lc[dim], 1) : LinRange(g.lc[dim], g.hc[dim], g.n[dim])

"""
    dimension(g::CartesianGrid)

Return the dimension of the Cartesian grid `g`.
"""
dimension(g::CartesianGrid{N}) where {N} = N


xgrid(g::CartesianGrid) = grid1d(g, 1)
ygrid(g::CartesianGrid) = grid1d(g, 2)
zgrid(g::CartesianGrid) = grid1d(g, 3)

"""
    meshsize(g::CartesianGrid)

Return the grid spacing (node spacing) of the Cartesian grid `g` in each dimension.
"""
meshsize(g::CartesianGrid) = (g.hc .- g.lc) ./ max.(g.n .- 1, 1)
meshsize(g::CartesianGrid, dim) = (g.hc[dim] - g.lc[dim]) / max(g.n[dim] - 1, 1)

Base.size(g::CartesianGrid) = g.n
Base.length(g) = prod(size(g))

function Base.getindex(g::CartesianGrid{N}, I::CartesianIndex{N}) where {N}
    I ∈ CartesianIndices(g) || throw(ArgumentError("index $I is out of bounds"))
    return _getindex(g, I)
end

Base.getindex(g::CartesianGrid, I::Int...) = g[CartesianIndex(I...)]

Base.eltype(g::CartesianGrid) = typeof(g.lc)

function _getindex(g::CartesianGrid, I::CartesianIndex)
    N = dimension(g)
    @assert N == length(I)
    return ntuple(N) do dim
        return g.lc[dim] + (I[dim] - 1) / (g.n[dim] - 1) * (g.hc[dim] - g.lc[dim])
    end |> SVector
end
_getindex(g::CartesianGrid, I::Int...) = _getindex(g, CartesianIndex(I...))

Base.CartesianIndices(g::CartesianGrid) = CartesianIndices(size(g))
Base.eachindex(g::CartesianGrid) = CartesianIndices(g)

function interior_indices(g::CartesianGrid, P::Int)
    N = dimension(g)
    sz = size(g)
    I = ntuple(N) do dim
        return (P + 1):(sz[dim] - P)
    end
    return CartesianIndices(I)
end

# iterate over all nodes
function Base.iterate(g::CartesianGrid)
    i = first(CartesianIndices(g))
    return g[i], i
end

function Base.iterate(g::CartesianGrid, state)
    idxs = CartesianIndices(g)
    next = iterate(idxs, state)
    if next === nothing
        return nothing
    else
        i, state = next
      
  return g[i], state
    end
end

Base.IteratorSize(::CartesianGrid{N}) where {N} = Base.HasShape{N}()

"""
    cell_spacing(g::CartesianGrid)

Return the cell spacing of the Cartesian grid `g` in each dimension. The cell spacing is defined as Δx = (hc - lc) / n, where n is the number of cells (not nodes) in each direction.
"""
cell_spacing(g::CartesianGrid) = (g.hc .- g.lc) ./ g.n
cell_spacing(g::CartesianGrid, dim) = (g.hc[dim] - g.lc[dim]) / g.n[dim]

"""
    cell_center(g::CartesianGrid, I)

Return the center coordinates of the cell indexed by `I` in the Cartesian grid `g`. The cell center is computed as lc + (I - 0.5) * Δ, where Δ is the cell spacing.
"""
function cell_center(g::CartesianGrid{N}, I::CartesianIndex{N}) where {N}
    Δ = cell_spacing(g)
    return SVector(ntuple(d -> g.lc[d] + (I[d] - 0.5) * Δ[d], N))
end

end # module
