```@meta
CurrentModule = CartesianGrids
```

# CartesianGrids.jl

## Installation

```julia
using Pkg
Pkg.add("CartesianGrids")
```

## Overview

`CartesianGrids.jl` is a Julia package for uniform Cartesian grid generation and management. It provides efficient tools for creating and manipulating structured grids in arbitrary dimensions.

The package includes:
- Grid creation with customizable dimensions and node counts
- Efficient node and cell spacing calculations
- Grid indexing and iteration utilities
- Type-stable implementations using StaticArrays

## Quick Example

```@example
using CartesianGrids, StaticArrays

# Create a 2D Cartesian grid: [-1,1]² with 32 nodes in each direction
grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))

# Get node spacing (distance between adjacent nodes)
meshsize = CartesianGrids.meshsize(grid)
# Returns: [2/31, 2/31] (since 32 nodes over distance 2)

# Get cell spacing (cell width)
cell_spacing = CartesianGrids.cell_spacing(grid)
# Returns: [2/32, 2/32]

# Extract 1D grid along a dimension
x_grid = CartesianGrids.grid1d(grid, 1)
# Returns: LinRange(-1.0, 1.0, 32)

# Get coordinates of a specific grid point
coords = grid[CartesianIndex(1, 1)]
# Returns: [-1.0, -1.0]

# Get cell center coordinates
center = CartesianGrids.cell_center(grid, CartesianIndex(1, 1))
# Returns: [-31/32, -31/32] (center of first cell)
```

## Drawing

```text
	y
	↑
	|
	|   o───o───o  ← hc = (x_H, y_H)
	|   │   │   │
	|   o───o───o
	|   │   │   │
	|   o───o───o
	|   ↑
    |   lc = (x_L, y_L)
	+────────────→ x
```

with `n = (nx, ny) = (3, 3)` nodes per dimension, `lc` the lower corner, and `hc` the upper corner. `o` denotes grid nodes, and the lines indicate cell edges. The grid is uniform, so node spacing is constant in each direction. Top left node : `(i=1, j=3)`, center node : `(i=2, j=2)`.

## Main Sections

- [Grid Types](grid-types.md)
- [API Reference](reference.md)

## Performance

The package is designed for efficiency with:
- Allocation-free operations where possible
- Type-stable implementations using StaticArrays
- Fast indexing and iteration over grid points
