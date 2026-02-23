```@meta
CurrentModule = CartesianGrids
```

# API Reference

## Grid Queries

```@docs
dimension
grid1d
meshsize
cell_spacing
cell_center
```

## Indexing and Iteration

- `Base.size(g::CartesianGrid)` — Get grid size (number of nodes per dimension)
- `Base.length(g::CartesianGrid)` — Get total number of nodes
- `Base.getindex(g::CartesianGrid, I::CartesianIndex)` — Access a grid point
- `Base.eachindex(g::CartesianGrid)` — Iterate over all grid indices
- `Base.CartesianIndices(g::CartesianGrid)` — Get CartesianIndices for the grid
- `Base.iterate(g::CartesianGrid)` — Iterate over all grid points
