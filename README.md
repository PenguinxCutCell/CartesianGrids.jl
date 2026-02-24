# CartesianGrids.jl

[![In development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://PenguinxCutCell.github.io/CartesianGrids.jl/dev)
![CI](https://github.com/PenguinxCutCell/CartesianGrids.jl/workflows/CI/badge.svg)

A Julia package for uniform Cartesian grid generation and management.

## Features

- Create uniform Cartesian grids in arbitrary dimensions
- Efficient node and cell spacing calculations
- Integration with StaticArrays for type stability
- Full support for multi-dimensional grids

## Installation

After cloning the repo,

```julia
using Pkg
Pkg.dev("CartesianGrids")
```

## Quick Example

```julia
using CartesianGrids, StaticArrays

# Create a 2D Cartesian grid: [-1,1]² with 32 nodes in each direction
grid = CartesianGrid((-1.0, -1.0), (1.0, 1.0), (32, 32))

# Get node spacing (node-to-node distance)
spacing = CartesianGrids.meshsize(grid)

# Get cell spacing (cell width)
cell_spacing = CartesianGrids.cell_spacing(grid)

# Extract 1D grid along dimension 1
x_grid = CartesianGrids.grid1d(grid, 1)

# Get cell center for a specific cell
center = CartesianGrids.cell_center(grid, CartesianIndex(1, 1))
```

## License

This package is part of the PenguinxCutCell project.
