
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
        - C : Vector{Vector{Vector{Int64}}} vectors of 2*(N[0]+N[1]) elements
              representing the path. Each element of C has 3 items, the two
              firsts are coordinate and the third is equal to 1 is the box is
              before a mirror 0 otherwise.
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

function UndeadInstance(inst::UndeadInstance)
    N = copy(inst.N)
    X = copy(inst.X)
    Z = inst.Z
    G = inst.G
    V = inst.V
    C = copy(inst.C)
    Y = copy(inst.Y)
    return UndeadInstance(N, X, Z, G, V, C, Y)
end

struct HeuristicInstance
    str_rep::String
    N::Array{Int64}
    X::Array{Int64,2}
    Z::Int64
    G::Int64
    V::Int64
    C::Vector{Vector{Vector{Int64}}}
    Y::Array{Int64}
    P::Array{Vector{Int64},2} # Matrice des possibilites
    tuple_Y::Vector{Vector{Int64}}
end

function HeuristicInstance(inst::UndeadInstance)

    N = copy(inst.N)
    X = copy(inst.X)
    Z = inst.Z
    G = inst.G
    V = inst.V
    C = copy(inst.C)
    Y = copy(inst.Y)
    str_rep = ""
    str_rep *= string(Z)
    str_rep *= string(G)
    str_rep *= string(V)
    for i  in inst.X
        str_rep *= string(i)
    end
    P = get_possibilities(inst)

    tuple_Y = Vector{Vector{Int64}}(undef,0)
    for i in 1:size(inst.C,1)
        push!(tuple_Y, [i, length(inst.C[i])])
    end

    # Since it doesn't change we can compute it once
    sort!(tuple_Y, by= x -> x[2])
    # println(log, "tuple_Y = $tuple_Y")

    return HeuristicInstance(str_rep, N, X, Z, G, V, C, Y, P, tuple_Y)
end



function get_unfilled_boxes(inst::HeuristicInstance)
    res = Vector{Vector{Int64}}(undef, 0)
    N = inst.N
    for i in 1:N[1]
        for j in 1:N[2]
            if inst.X[i,j] == 0
                push!(res, [i,j,0])
            end
        end
    end
    return res
end

function is_contained_get_value(path::Vector{Vector{Int64}}, i::Int64, j::Int64)
    for el in path
        if el[1] == i && el[2] == j
            return (true, el[3])
        end
    end
    return (false, 0)
end


function get_paths_in_stakes(inst, i::Int64, j::Int64)
    paths = Vector{Vector{Int64}}(undef, 0)
    # Get indices of paths that contained the box and the value associated with
    for k in 1:size(inst.C, 1)
        is_contained, value = is_contained_get_value(inst.C[k], i, j)
        if is_contained
            push!(paths, [k, value, inst.Y[k]])
        end
    end
    return paths
end

"""
Function that create the matrix of possibilites for a given instance.
"""
function get_possibilities(inst)
    N = inst.N
    P = Array{Vector{Int64},2}(undef, N[1], N[2])
    for i in 1:N[1]
        for j in 1:N[2]
            if inst.X[i,j] == 0
                paths_in_stakes = get_paths_in_stakes(inst, i, j)

                # fecthing conditions
                possibility = Vector{Int64}(undef, 0)

                # Testing if we can add a zombie
                if inst.Z > 0
                    is_valid = reduce(&, map(x->x[3] - 1 >= 0, paths_in_stakes))
                    if is_valid
                        push!(possibility, 2)
                    end
                end
                # Testing if we can add a ghost
                if inst.G > 0
                    is_valid = reduce(&, map(x->(x[2] != 0 || x[3] - 1 >= 0) && (x[3] - get_unfilled(inst,x[1]) <=0)
                                             , paths_in_stakes))
                    if is_valid
                        push!(possibility, 1)
                    end
                end

                # Testing if we can add a vampire
                if inst.V > 0
                    is_valid = reduce(&, map(x->(x[2] != 1 || x[3] - 1 >= 0) && (x[3] - get_unfilled(inst,x[1]) <=0),
                                             paths_in_stakes))
                    if is_valid
                        push!(possibility, 3)
                    end
                end


                P[i,j] = possibility

            else
                # FIXME: See how to represent when no possibility is required for a box
                P[i,j] = [4,4,4,4]
            end
        end
    end
    return P
end

function get_unfilled(inst,path)
    unfilled = 0
    for cell in inst.C[path]
        if inst.X[cell[1], cell[2]] == 0
            unfilled +=1
        end
    end
    return unfilled
end

# TODO: let the user define the function by for the sort algorithm
"""
Funtion that sort the vector of cells by the ascending number of possibilities.
"""
function sort_by_possibilities(inst::HeuristicInstance, cells::Vector{Vector{Int64}})
    return sort(cells, by = x->length(get_paths_in_stakes(inst, x[1], x[2])))

    # return sort(cells, by=x -> length(inst.P[x[1],x[2]]) *
    #             (1 - length(get_paths_in_stakes(inst,x[1],x[2]))/length(inst.Y) ))
end

function sort_by_paths_length(inst::HeuristicInstance, cells::Vector{Vector{Int64}})
    return sort(cells,
                by = cell ->
                minimum( map( path -> length( inst.C[path[1]] ),
                          get_paths_in_stakes( inst, cell[1], cell[2] ) ) ) )
end


function sort_by_path(inst::HeuristicInstance, cells::Vector{Vector{Int64}},log)
    res = Vector{Vector{Int64}}(undef,0)
    for path in inst.tuple_Y
        # filter cells that is involved in path[1] then sort them by  number of possibilities
        to_be_pushed = sort(filter( cell -> path[1] in map( x -> x[1], get_paths_in_stakes(inst,cell[1], cell[2])), cells), by = y -> length(inst.P[y[1], y[2]]))
        for el in to_be_pushed
            if !(el in res)
                push!(res, el)
            end
        end
    end
    return res
end


function create_modified(inst::HeuristicInstance, i::Int64, j::Int64, v::Int64)
    if v > 0 && v < 4 && inst.X[i,j] == 0
        N = copy(inst.N)
        X = copy(inst.X)
        G = inst.G
        Z = inst.Z
        V = inst.V
        C = copy(inst.C)
        Y = copy(inst.Y)

        # we update X
        X[i,j] = v
        # We update for the total number of typed v monster
        if v == 1
            G -= 1
        elseif v == 2
            Z -= 1
        else
            V -= 1
        end

        # Update Y
        paths_in_stakes = get_paths_in_stakes(inst, i, j)

        for el in paths_in_stakes
            if v == 1
                if el[2] == 0
                    Y[ el[1] ] -= 1
                end
            elseif v == 2
                Y[ el[1] ] -= 1
            else
                if el[2] == 1
                    Y[ el[1] ] -= 1
                end
            end
        end

        # We create a copy of the HeuristicInstance
        new_inst = HeuristicInstance(UndeadInstance(N, X, Z, G, V, C, Y))
        return new_inst
    end
    return nothing
end


"""
Function that test whether an instance is valid. It tests four things :
 - if there is enough monsters to fill the grid,
 - if on each path we don't see too much monsters,
 - if there is no path that filled in monsters but one don't see the good count
   of monsters,
 - if each unfilled cell have possibilities to be filled.
"""
function is_valid(inst::HeuristicInstance)
    # Test whether there is a type of monster that is over use
    if inst.Z < 0 || inst.G < 0 || inst.V < 0
        return false
    end

    for i in 1:size(inst.C,1)
        # Test whether there is a path that is impossible
        if inst.Y[i] > 0
            unfilled = 0
            for coord in inst.C[i]
                if inst.X[coord[1], coord[2]] == 0
                    unfilled +=1
                end
            end
            # Test whether there is a path on which we see too many monsters
            if unfilled  == 0
                return false
            end

            if inst.Y[i] - unfilled > 0
                return false
            end
        end

        if inst.Y[i] < 0
            return false
        end
    end

    # Test whether there is a box with no possibility and that it is not filled
    for i in 1:inst.N[1]
        for j in 1:inst.N[2]
            if length(inst.P[i,j]) == 0
                return false
            end
        end
    end
    return true
end

function is_finished(inst::HeuristicInstance)
    # Test whether there is a type of monster that is over use
    if inst.Z != 0 || inst.G != 0 || inst.V != 0
        return false
    end

    # Test whether there is a path on which we see too much monsters
    for i in inst.Y
        if i != 0
            return false
        end
    end

    # Test whether there is a box with no possibility
    for i in 1:inst.N[1]
        for j in 1:inst.N[2]
            if length(inst.P[i,j]) != 4
                return false
            end
        end
    end
    return true
end
