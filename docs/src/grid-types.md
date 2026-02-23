```@meta
CurrentModule = CartesianGrids
```

# Grid Types

## CartesianGrid

```@docs
CartesianGrid
```

### Structure

A `CartesianGrid{N, T}` represents a uniform Cartesian grid in `N` dimensions with floating-point coordinates of type `T`.

#### Fields

- `lc::SVector{N, T}` — lower corner coordinates
- `hc::SVector{N, T}` — upper corner coordinates  
- `n::NTuple{N, Int}` — number of nodes in each dimension

### Creating a Grid

```@example
using CartesianGrids

# 2D grid: [-1,1]² with 32 nodes per direction
grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))

# 3D grid: [-2,2]³ with varying node counts
grid3d = CartesianGrid((-2.0, -2.0, -2.0), (2.0, 2.0, 2.0), (16, 32, 64))
```

### Accessing Grid Information

```@example
using CartesianGrids

# Create a 2D grid
grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))

# Get grid size (number of nodes per dimension)
size(grid)  # (32, 32)

# Get total number of nodes
length(grid)  # 1024

# Get dimension count
CartesianGrids.dimension(grid)  # 2

# Get 1D grid for a specific dimension
x_grid = CartesianGrids.grid1d(grid, 1)  # LinRange(-1.0, 1.0, 32)

# Get all 1D grids
all_grids = CartesianGrids.grid1d(grid)  # (x_grid, y_grid)
```

### Grid Spacing

```@example
using CartesianGrids

# Create a 2D grid
grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))

# Node spacing (distance between adjacent nodes)
spacing = CartesianGrids.meshsize(grid)  # [2/31, 2/31]

# Node spacing for a specific dimension
x_spacing = CartesianGrids.meshsize(grid, 1)  # 2/31

# Cell spacing (cell width)
cell_spacing = CartesianGrids.cell_spacing(grid)  # [2/32, 2/32]

# Cell spacing for a specific dimension
x_cell_spacing = CartesianGrids.cell_spacing(grid, 1)  # 2/32
```

### Indexing and Iteration

```@example
using CartesianGrids

# Create a 2D grid
grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))

# Access a grid point by Cartesian index
coords = grid[CartesianIndex(1, 1)]  # SVector(-1.0, -1.0)
coords = grid[1, 1]  # Same as above

# Get cell center coordinates
center = CartesianGrids.cell_center(grid, CartesianIndex(1, 1))

# Iterate over all grid points
for coords in grid
    println(coords)
end

# Get CartesianIndices for the grid
indices = CartesianGrids.CartesianIndices(grid)  # CartesianIndices((32, 32))
```

## AbstractMesh

```@docs
AbstractMesh
```

All grid types in CartesianGrids inherit from `AbstractMesh{N, T}` where:
- `N` is the dimension
- `T` is the floating-point type
