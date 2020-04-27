"""
    Struct representing a instance of a galaxies problem.
    Struct attribute are :
        - N : tuple (X,Y) of Int64 representing the dimension of the grid where X is the number of lines and Y the number of columns
        - X : Array{Int64, 2} grid representation. The X[i,j] = 0 if it belongs to no galaxy, the index of the galaxy otherwise
        - C : Vector{Vector{Int64}} represents the centers of the galaxies, with the super-index.
              super-index : Except for the lines at the edges of the grid, the lines AND the centers of the grids have indices.
           1 2 3 4 5
          --- --- ---
    1 -> |   |   |   |
    2 ->  --- --- ---
    3 -> |   |   |   |
          --- --- ---

"""
struct GalaxyInstance
    N::Array{Int64}
    X::Array{Int64,2}
    C::Vector{Vector{Int64}}
end