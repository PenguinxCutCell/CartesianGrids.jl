module CartesianGrids

using StaticArrays

export CartesianGrid, SpaceTimeCartesianGrid, grid1d, meshsize, cell_spacing, cell_center, dimension, CartesianIndices, interior_indices, collect!

"""
    abstract type AbstractMesh{N,T}

An abstract mesh structure in dimension `N` with primite data of type `T`.
"""
abstract type AbstractMesh{N, T} end

abstract type AbstractCartesianGrid{N, T} <: AbstractMesh{N, T} end

struct CartesianGrid{N, T} <: AbstractCartesianGrid{N, T}
    lc::SVector{N, T}
    hc::SVector{N, T}
    n::NTuple{N, Int}
end

struct SpaceTimeCartesianGrid{N, T} <: AbstractCartesianGrid{N, T}
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
    SpaceTimeCartesianGrid(lc, hc, n)

Create a dedicated space-time uniform Cartesian grid.
"""
function SpaceTimeCartesianGrid(lc, hc, n)
    length(lc) == length(hc) == length(n) ||
        throw(ArgumentError("all arguments must have the same length"))
    N = length(lc)
    lc_ = SVector{N, eltype(lc)}(lc...)
    hc_ = SVector{N, eltype(hc)}(hc...)
    n = ntuple(i -> Int(n[i]), N)
    return SpaceTimeCartesianGrid(promote(lc_, hc_)..., n)
end

"""
    SpaceTimeCartesianGrid(space_grid::CartesianGrid, time)

Create a space-time grid by appending `time` as the last dimension.
"""
function SpaceTimeCartesianGrid(space_grid::CartesianGrid{N, T}, time) where {N, T}
    length(time) > 0 || throw(ArgumentError("time must contain at least one node"))
    lc = (Tuple(space_grid.lc)..., first(time))
    hc = (Tuple(space_grid.hc)..., last(time))
    n = (space_grid.n..., length(time))
    return SpaceTimeCartesianGrid(lc, hc, n)
end

"""
    grid1d(g::CartesianGrid, dim)

Return the 1D grid points along the specified dimension `dim` of the Cartesian grid `g`.
"""
grid1d(g::AbstractCartesianGrid{N}) where {N} = ntuple(i -> grid1d(g, i), N)
grid1d(g::AbstractCartesianGrid, dim) = g.n[dim] == 1 ? LinRange(g.lc[dim], g.lc[dim], 1) : LinRange(g.lc[dim], g.hc[dim], g.n[dim])

"""
    dimension(g::CartesianGrid)

Return the dimension of the Cartesian grid `g`.
"""
dimension(g::AbstractCartesianGrid{N}) where {N} = N


xgrid(g::AbstractCartesianGrid) = grid1d(g, 1)
ygrid(g::AbstractCartesianGrid) = grid1d(g, 2)
zgrid(g::AbstractCartesianGrid) = grid1d(g, 3)

"""
    meshsize(g::CartesianGrid)

Return the grid spacing (node spacing) of the Cartesian grid `g` in each dimension. This is computed as (hc - lc) / (n - 1), since there are n-1 intervals between n nodes.
"""
meshsize(g::AbstractCartesianGrid) = (g.hc .- g.lc) ./ max.(g.n .- 1, 1)
meshsize(g::AbstractCartesianGrid, dim) = (g.hc[dim] - g.lc[dim]) / max(g.n[dim] - 1, 1)

Base.size(g::AbstractCartesianGrid) = g.n
Base.length(g::AbstractCartesianGrid) = prod(size(g))

function Base.getindex(g::AbstractCartesianGrid{N}, I::CartesianIndex{N}) where {N}
    I ∈ CartesianIndices(g) || throw(ArgumentError("index $I is out of bounds"))
    return _getindex(g, I)
end

Base.getindex(g::AbstractCartesianGrid, I::Int...) = g[CartesianIndex(I...)]

Base.eltype(g::AbstractCartesianGrid) = typeof(g.lc)

function _getindex(g::AbstractCartesianGrid, I::CartesianIndex)
    N = dimension(g)
    @assert N == length(I)
    return ntuple(N) do dim
        return g.lc[dim] + (I[dim] - 1) / (g.n[dim] - 1) * (g.hc[dim] - g.lc[dim])
    end |> SVector
end
_getindex(g::AbstractCartesianGrid, I::Int...) = _getindex(g, CartesianIndex(I...))

Base.CartesianIndices(g::AbstractCartesianGrid) = CartesianIndices(size(g))
Base.eachindex(g::AbstractCartesianGrid) = CartesianIndices(g)

function interior_indices(g::AbstractCartesianGrid, P::Int)
    N = dimension(g)
    sz = size(g)
    I = ntuple(N) do dim
        return (P + 1):(sz[dim] - P)
    end
    return CartesianIndices(I)
end

# iterate over all nodes
function Base.iterate(g::AbstractCartesianGrid)
    i = first(CartesianIndices(g))
    return g[i], i
end

function Base.iterate(g::AbstractCartesianGrid, state)
    idxs = CartesianIndices(g)
    next = iterate(idxs, state)
    if next === nothing
        return nothing
    else
        i, state = next
      
  return g[i], state
    end
end

Base.IteratorSize(::AbstractCartesianGrid{N}) where {N} = Base.HasShape{N}()

"""
    cell_spacing(g::CartesianGrid)

Return the cell spacing between cell centers in each dimension of the Cartesian grid `g`. This is computed as (hc - lc) / n, since there are n cells spanning the distance from lc to hc.
"""
cell_spacing(g::AbstractCartesianGrid) = (g.hc .- g.lc) ./ g.n
cell_spacing(g::AbstractCartesianGrid, dim) = (g.hc[dim] - g.lc[dim]) / g.n[dim]

"""
    cell_center(g::CartesianGrid, I)

Return the center coordinates of the cell indexed by `I` in the Cartesian grid `g`. The cell center is computed as lc + (I - 0.5) * Δ, where Δ is the cell spacing.
"""
function cell_center(g::AbstractCartesianGrid{N}, I::CartesianIndex{N}) where {N}
    Δ = cell_spacing(g)
    return SVector(ntuple(d -> g.lc[d] + (I[d] - 0.5) * Δ[d], N))
end


"""
    collect!(dest, g)

Fill a preallocated container `dest` with the node coordinates from the Cartesian grid `g`.
This avoids allocating a new array (unlike `collect(g)`).

Supported forms:
- `collect!(v::AbstractVector, g::CartesianGrid)` fills `v` in linear (column-major) order.
- `collect!(A::AbstractArray{<:Any,N}, g::CartesianGrid{N})` fills the N-dimensional array `A` using the same index layout as the grid.
"""
function collect!(dest::AbstractVector, g::AbstractCartesianGrid)
    length(dest) == length(g) || throw(ArgumentError("dest must have length $(length(g))"))
    i = 1
    for I in CartesianIndices(g)
        dest[i] = _getindex(g, I)
        i += 1
    end
    return dest
end

function collect!(dest::AbstractArray, g::AbstractCartesianGrid{N, T}) where {N, T}
    size(dest) == size(g) || throw(ArgumentError("dest must have the same size as grid"))
    for I in CartesianIndices(g)
        dest[I] = _getindex(g, I)
    end
    return dest
end

function Base.collect(g::AbstractCartesianGrid)
    return [g[I] for I in CartesianIndices(g)]
end

end # module
