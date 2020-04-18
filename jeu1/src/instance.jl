
"""
    Struct representing a instance of a undead problem.
    Struct attribute are :
        - N : tuple (X,Y) of Int64 representing the dimension of the instance where X is the number of lines and Y the number of columns
        - X : Array{Int64, 2} grid representation. Each box can have :
            - 0 : means empty
            - 1 : means ghost
            - 2 : means zombie
            - 3 : means vampire
            - 4 : means mirror /
            - 5 : means mirror \\
        - Z : Int64 , total number of zombies in the instance / on the grid
        - G : Int64 , total number of ghosts in the instance / on the grid
        - V : Int64 , total number of vampires in the instance / on the grid
        - C : Vector{Vector{Vector{Int64}}} vectors of 2*(N[0]+N[1]) elements representing the path.
        - Y : Array{Int64} of 2*(N[0]+ N[1]) representing the number of visible monster for each path.
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
