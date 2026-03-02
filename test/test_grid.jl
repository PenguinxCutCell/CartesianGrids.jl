using StaticArrays
using Test
using CartesianGrids

@testset "grid" begin
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    @test CartesianGrids.meshsize(grid) ≈ SVector(2 / 31, 2 / 31) # node spacing
    @test CartesianGrids.cell_spacing(grid) ≈ SVector(2 / 32, 2 / 32) # cell spacing

    cc = CartesianGrids.cell_center(grid, CartesianIndex(1, 1))
    @test cc ≈ SVector(-1.0 + 1 / 32, -1.0 + 1 / 32)
end

@testset "grid1d" begin
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    @test CartesianGrids.grid1d(grid, 1) ≈ LinRange(-1.0, 1.0, 32)
    @test CartesianGrids.grid1d(grid, 2) ≈ LinRange(-1.0, 1.0, 32)
end

@testset "grid4d" begin
    grid = CartesianGrid((-1.0, -1.0, -1.0, -1.0), (1.0, 1.0, 1.0, 1.0), (32, 32, 32, 32))
    @test CartesianGrids.grid1d(grid, 3) ≈ LinRange(-1.0, 1.0, 32)
end

@testset "CartesianIndices" begin
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    @test CartesianGrids.CartesianIndices(grid) == CartesianIndices((32, 32))
end

@testset "space-time grid" begin
    # 2D grid [-1,1]^2 with 32 nodes in each direction + time dimension [0,\Delta t] with 2 nodes
    grid = CartesianGrid((-1.0, -1.0, 0.0), (1.0, 1.0, 0.1), (32, 32, 2))
    @test CartesianGrids.grid1d(grid, 1) ≈ LinRange(-1.0, 1.0, 32)
    @test CartesianGrids.grid1d(grid, 2) ≈ LinRange(-1.0, 1.0, 32)
    @test CartesianGrids.grid1d(grid, 3) ≈ LinRange(0.0, 0.1, 2)
    @test CartesianGrids.meshsize(grid) ≈ SVector(2 / 31, 2 / 31, 0.1)
end


@testset "SpaceTimeCartesianGrid struct" begin
    st = SpaceTimeCartesianGrid((-1.0, -1.0, 0.0), (1.0, 1.0, 0.1), (32, 32, 2))
    @test dimension(st) == 3
    @test size(st) == (32, 32, 2)
    @test CartesianGrids.grid1d(st, 3) ≈ LinRange(0.0, 0.1, 2)
    @test CartesianGrids.meshsize(st) ≈ SVector(2 / 31, 2 / 31, 0.1)
    @test CartesianGrids.cell_spacing(st) ≈ SVector(2 / 32, 2 / 32, 0.05)

    space = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    st2 = SpaceTimeCartesianGrid(space, [0.0, 0.05, 0.1])
    @test size(st2) == (32, 32, 3)
    @test CartesianGrids.grid1d(st2, 3) ≈ LinRange(0.0, 0.1, 3)
    @test st2[1, 1, 1] ≈ SVector(-1.0, -1.0, 0.0)

    c = Vector{eltype(st2)}(undef, length(st2))
    collect!(c, st2)
    @test c[1] ≈ st2[CartesianIndex(1, 1, 1)]
    @test c[end] ≈ st2[CartesianIndex(32, 32, 3)]
end

@testset "cell centers" begin
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    for I in CartesianGrids.CartesianIndices(grid)
        cc = CartesianGrids.cell_center(grid, I)
        @test cc ≈ SVector(-1.0 + (I[1] - 0.5) * 2 / 32, -1.0 + (I[2] - 0.5) * 2 / 32)
    end
end

@testset "interior indices" begin
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    interior = CartesianGrids.interior_indices(grid, 1)
    @test length(interior) == 30 * 30
    @test all(I -> I[1] > 1 && I[1] < 32 && I[2] > 1 && I[2] < 32, interior)
end


@testset "additional exports" begin
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    @test dimension(grid) == 2

    # scalar overloads for meshsize and cell spacing
    @test CartesianGrids.meshsize(grid, 1) ≈ 2 / 31
    @test CartesianGrids.meshsize(grid, 2) ≈ 2 / 31
    @test CartesianGrids.cell_spacing(grid, 1) ≈ 2 / 32
    @test CartesianGrids.cell_spacing(grid, 2) ≈ 2 / 32

    # ntuple-returning grid1d method
    grids = CartesianGrids.grid1d(grid)
    @test length(grids) == 2
    @test grids[1] ≈ LinRange(-1.0, 1.0, 32)
    @test grids[2] ≈ LinRange(-1.0, 1.0, 32)

    # dimension for higher-dim grid
    grid4 = CartesianGrid((-1.0, -1.0, -1.0, -1.0), (1.0, 1.0, 1.0, 1.0), (32, 32, 32, 32))
    @test dimension(grid4) == 4
end


@testset "coverage missing" begin
    # constructor argument length mismatch throws
    @test_throws ArgumentError CartesianGrid((0.0,), (1.0, 1.0), (2,))

    # grid1d when n == 1 should return a single-point LinRange
    g1 = CartesianGrid((0.0, 0.0), (1.0, 2.0), (1, 3))
    @test CartesianGrids.grid1d(g1, 1) == LinRange(0.0, 0.0, 1)
    @test CartesianGrids.grid1d(g1, 2) ≈ LinRange(0.0, 2.0, 3)

    # getindex out-of-bounds raises
    g = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (4, 4))
    @test_throws ArgumentError g[CartesianIndex(0, 1)]

    # integer varargs getindex matches CartesianIndex form
    @test g[1, 1] ≈ g[CartesianIndex(1, 1)]

    # iterate over full grid values
    arr = collect(g)
    @test length(arr) == prod(size(g))
    @test arr[1] ≈ g[CartesianIndex(1, 1)]
    @test arr[end] ≈ g[CartesianIndex(4, 4)]

    # eltype returns the type of the lower-corner SVector
    @test eltype(g) == typeof(g.lc)

    # test collect! with preallocated output array
    c = Vector{eltype(g)}(undef, length(g))
    collect!(c, g)
    @test length(c) == prod(size(g))
    @test c[1] ≈ g[CartesianIndex(1, 1)]
    @test c[end] ≈ g[CartesianIndex(4, 4)]
end
