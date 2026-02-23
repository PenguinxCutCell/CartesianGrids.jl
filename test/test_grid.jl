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


@testset "allocations" begin
    # check that common queries allocate no heap memory
    grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))
    # warm up (compile) before measuring allocations
    meshsize(grid)
    cell_spacing(grid)
    grid1d(grid, 1)
    grid[CartesianIndex(1, 1)]
    GC.gc()

    # allow small (compile/runtime) allocations but ensure no large heap usage
    @test @allocated(meshsize(grid)) <= 128
    @test @allocated(cell_spacing(grid)) <= 128

    # retrieving 1D grid and a single node should allocate only minimally
    @test @allocated(grid1d(grid, 1)) <= 128
    @test @allocated(grid[CartesianIndex(1, 1)]) <= 128
end