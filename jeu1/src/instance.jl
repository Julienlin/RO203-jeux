
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

function get_unfilled_cells(inst::UndeadInstance)
    res = Vector{Vector{Int64}}
    for i in 1:N[1]
        for j in 1:N[2]
            if inst.X[i,j] == 0
                append!(res, [i,j,0])
            end
        end
    end
    return res
end


struct HeuristicInstance
    N::Array{Int64}
    X::Array{Int64,2}
    Z::Int64
    G::Int64
    V::Int64
    C::Vector{Vector{Vector{Int64}}}
    Y::Array{Int64}
    P:: Array{Vector{Int64},2} #Matrice des possibilites
end

function HeuristicInstance(inst::UndeadInstance)
    N = copy(inst.N)
    X = copy(inst.X)
    Z = inst.Z
    G = inst.G
    V = inst.V
    C = copy(inst.C)
    Y = copy(inst.Y)
    P = get_possibilities(inst)
    return HeuristicInstance(N,X,Z,G,V,C,Y,P)
end




function get_possibilities(inst::UndeadInstance)
    P = Array{Vector{Int64},2}
    for i in 1:N[1]
        for j in 1:N[2]
            if inst.X[i,j] == 0
                paths_in_stakes = Vector{Vector{Int64}}

                # Get indices of paths that contained the box and the value associated with
                for k in 1:size(inst.C,1)
                    is_contained, value = is_contained_get_value(inst.C[k],i,j)
                    if is_contained
                        append!(path_in_stakes, [k,value,Y[k]])
                    end
                end

                # fecthing conditions

            end
        end
    end
end

function is_contained_get_value( path::Vector{Vector{Int64}}, i::Int64, j::Int64 )
    for el in path
        if el[1] == i && el[2] == j
            return true, el[3]
        end
    end
    return false, 0
end



function sort_cells_by_possibilities(inst::UndeadInstance, cells::Vector{Vector{Int64}})
   return sort(cells, by=x -> x[3])
end
