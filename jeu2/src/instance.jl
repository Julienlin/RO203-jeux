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

struct HeuristicInstance
    N::Array{Int64}
    X::Array{Int64,2}
    C::Vector{Vector{Int64}}
    # Dans cette matrice, on stocke les coordonnees des cases de la "frontiere" de chaque galaxie, a partir desquelles elle peut etre etendue
    frontieres::Vector{Vector{Int64}}
end

function GalaxyToHeuristic(inst::GalaxyInstance,front)
    N= copy(inst.N)
    X= copy(inst.X)
    C= copy(inst.C)
    F=copy(front)
    return HeuristicInstance(N,X,C,F)
end