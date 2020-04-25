"""
    Struct representing a instance of a galaxies problem.
    Struct attribute are :
        - N : tuple (X,Y) of Int64 representing the dimension of the grid where X is the number of lines and Y the number of columns
        - X : Array{Int64, 2} grid representation. The X[i,j] = 0 if it belongs to no galaxy, the number of the galaxy otherwise
        - C : Array{Int64, 2} represents the centers of the galaxies, with the super-indices.
    super-indices : Except for the lines at the edges of the grid, the lines AND the centers of the grids have indices. 
           1 2 3 4 5
          --- --- --- 
    1 -> |   |   |   |
    2 ->  --- --- --- 
    3 -> |   |   |   |
          --- --- --- 

"""
struct UndeadInstance
    N::Array{Int64}
    X::Array{Int64,2}
    Z::Int64
    G::Int64
    V::Int64
    C::Vector{Vector{Vector{Int64}}}
    Y::Array{Int64}
end