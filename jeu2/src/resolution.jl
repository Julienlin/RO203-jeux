# This file contains methods to solve an instance (heuristically or with CPLEX)
using CPLEX

include("generation.jl")
include("instance.jl")
include("io.jl")

TOL = 0.00001


function get_neighbours(N::Vector{Int64}, i::Int64, j::Int64)
    neighbours = Vector{Tuple{Int64,Int64}}(undef, 0)
    if i > 1
        push!(neighbours,  (i - 1, j))
    end
    if i < N[1]
        push!(neighbours, (i + 1, j))
    end
    if j > 1
        push!(neighbours, (i, j - 1))
    end
    if j < N[2]
        push!(neighbours, (i, j + 1))
    end
    return neighbours
end

"""
Solve an instance with CPLEX
"""
function cplexSolve(inst::GalaxyInstance)

    # Create the model
    m = Model(CPLEX.Optimizer)

    # TODO
    # println("In file resolution.jl, in method cplexSolve(), TODO: fix input and output, define the model")

    N = inst.N
    C = inst.C
    nb_galaxies = length(C)

    @variable(m, x[ 1:N[1], 1:N[2], 1:nb_galaxies], Bin)

    # constraint about symetry of each galaxy for the first dimension
    @constraint(m, [ g = 1:nb_galaxies ], sum((2 * i - 1 - C[g][1]) * x[i,j,g] for i in 1:N[1], j in 1:N[2]) == 0 )

    # constraint about symetry of each galaxy for the second dimension
    @constraint(m, [ g = 1:nb_galaxies], sum((2 * j - 1 - C[g][2]) * x[i,j,g] for j in 1:N[2], i in 1:N[1]) == 0 )


    # constraint about unicity of ownerhip for each box and that every box is owned
    @constraint(m, [ i = 1:N[1], j =  1:N[2] ], sum(x[i,j,g] for g in 1:nb_galaxies) == 1 )



    #  constraint for connexity
    for g in 1:nb_galaxies
        for i in 1:N[1]
            for j in 1:N[2]
                # this contraints has to be true, except if the node of the galaxy is in the center of the cell : one-cell galaxies are possible
                if 2 * j - 1 != C[g][2] || 2 * i - 1 != C[g][1]
                    # Determining neighbours
                    neighbours = get_neighbours(N, i, j)

                    # add constraint
                    @constraint(m, sum(x[ k, l , g] for (k, l) in neighbours)  >=  x[i,j,g])
                end
            end
        end
    end

    # constraint about the initial ownership : the cells touching the node of a galaxy has to belong to the galaxy

    for g in 1:nb_galaxies
        # if the center galaxy is on a corner
        if rem(C[g][1], 2) == 0 && rem(C[g][2], 2) == 0
            @constraint(m, [ i = [1, 0], j = [1, 0]], x[ div(C[g][1], 2) + i, div(C[g][2], 2) + j, g] == 1)
        end
        # if the center of the galaxy is on a horizontal border between two cells
        if rem(C[g][1], 2) == 0 && rem(C[g][2], 2) == 1
            @constraint(m, [ i in [1 ,0]], x[ div(C[g][1], 2) + i , div(C[g][2] + 1, 2), g] == 1)
        end
        # if the center of the galaxy is on a vertical border between two cells
        if rem(C[g][1], 2) == 1 && rem(C[g][2], 2) == 0
            @constraint(m, [j in [1, 0]], x[ div(C[g][1] + 1, 2), div(C[g][2], 2) + j, g] == 1)
        end
        # If the center of the galaxy is in a cell
        if rem(C[g][1], 2) == 1 && rem(C[g][2], 2) == 1
            @constraint(m, x[ div(C[g][1] + 1, 2), div(C[g][2] + 1, 2), g] == 1)
        end
    end
    # @constraint(m, [ g in 1:nb_galaxies, i in 1:N[1], j in 1:N[2];  ], x[ i, j , g ] == 1 )


    @objective(m, Min, 1)

    # Start a chronometer
    start = time()

    # Solve the model
    optimize!(m)

    buf = JuMP.value.(x)

    for i in 1:N[1]
        for j in 1:N[2]
            for g in 1:nb_galaxies
                if buf[i,j,g] == 1
                    inst.X[i,j] = g
                end
            end
        end
    end

    # @constraint(m, [ g in 1:nb_galaxies, i in 1:N[1], j in 1:N[2];  ], x[ i, j , g ] == 1 )


    # Return:
    # 1 - true if an optimum is found
    # 2 - the resolution time
    return JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT, time() - start

end

function head(A)
    return A[lastindex(A)]
end

"""
Heuristically solve an instance
"""
function heuristicSolve(inst::GalaxyInstance)

    start = time()

    C = inst.C
    X = inst.X
    N = inst.N

    # Pile des differents noeuds de l'arbre de resolution
    stack = Vector{HeuristicInstance}(undef, 0)

    #D'abord on contruit l'instance heuristique de l'instance a resoudre.
    #On initialise les frontieres aux cases "touchees" directement par les noyaux des galaxies

    # Dans cette matrice, on stocke les coordonnees des cases de la "frontiere" de chaque galaxie, a partir desquelles elle peut etre etendue
    frontieres = Vector{Vector{Int64}}(undef, 0)

    for i in 1:size(C,1)
        #Si le noyau est dans une case
        c = C[i]
        if rem(c[1],2)==1 && rem(c[2],2)==1
            x =div(c[1],2)+1
            y = div(c[2],2)+1
            X[x,y] = i
            push!(frontieres,[x,y])

        #Si le noyau est a cheval sur quatre cases
        elseif rem(c[1],2)==0 && rem(c[2],2)==0
            X[div(c[1]-1,2)+1 , div(c[2]-1,2)+1] = i
            X[div(c[1]-1,2)+1 , div(c[2]+1,2)+1] = i
            X[div(c[1]+1,2)+1 , div(c[2]-1,2)+1] = i
            X[div(c[1]+1,2)+1 , div(c[2]+1,2)+1] = i
            push!(frontieres, [div(c[1]-1,2)+1,div(c[2]-1,2)+1] , [div(c[1]+1,2)+1,div(c[2]-1,2)+1] , [div(c[1]-1,2)+1,div(c[2]+1,2)+1] , [div(c[1]+1,2)+1,div(c[2]+1,2)+1] )

       #Si le noyau est a cheval entre deux cases, sur une ligne horizontale
        elseif rem(c[1],2)==0 && rem(c[2],2)==1
            X[div(c[1]+1,2)+1 , div(c[2],2)+1 ] = i
            X[div(c[1]-1,2)+1 , div(c[2],2)+1 ] = i
            push!(frontieres, [div(c[1]+1,2)+1,div(c[2],2)+1] , [div(c[1]-1,2)+1,div(c[2],2)+1] )

        #Si le noyau est a cheval entre deux cases, sur une ligne verticale
        elseif rem(c[1],2)==1 && rem(c[2],2)==0
            X[div(c[1],2)+1 , div(c[2]+1,2)+1] = i
            X[div(c[1],2)+1 , div(c[2]-1,2)+1] = i
            push!(frontieres,  [div(c[1],2)+1,div(c[2]-1,2)+1 ] , [div(c[1],2)+1,div(c[2]+1,2)+1] )
        end
    end

    push!(stack, GalaxyToHeuristic(inst,frontieres))

    while !isempty(stack)
        cur = head(stack)
        isFull = isFilled(cur)
        if isFull
            # displayGridSolution(GalaxyInstance(cur.N,cur.X,cur.C))
            for i in 1:cur.N[1]
                for j in 1:cur.N[2]
                    inst.X[i,j] = cur.X[i,j]
                end
            end
            return true, time()-start
        end
        F = cur.frontieres
        isChild = false
        while !isChild #Tant qu'on n'a pas trouve d'enfant

            #On choisit la case de frontiere que l'on veut etendre
            n = size(F,1)
            j=n
            isCell = false
            #On cherche une cellule ayant un voisin encore non attribue
            while !isCell && j>0
                #Si la cellule n'a pas de voisin libre, on ne peut pas etendre de galaxie a partir d'elle, donc elle ne doit plus faire partie de la frontiere
                V = freeNeighbors(F[j],cur.X,cur.N)
                if isempty(V)
                    deleteat!(F, j)
                    j -= 1
                else
                    isCell = true
                end
            end
            if j==0
                println("Error : Grid filled !!!")
                return false, time()-start
            end
            cell = F[j]
            V = freeNeighbors(cell,cur.X,cur.N)

            #Parmi les voisins, on en cherche un dont le symetrique par rapport au centre de la galaxie est aussi libre (et dans la grille)
            v = 1
            n = size(V,1)
            while !isChild && v<=n

                #Calcul des coordonnees de la cellule symetrique
                new_cell = V[v]
                sym_cell = [0,0]
                if cur.X[cell[1],cell[2]] == 0
                    println("$(X[cell[1],cell[2]]) , $(cell[1]), $(cell[2])")
                    displayGridSolution(cur)
                end
                g = cur.C[cur.X[cell[1],cell[2]]]
                sym_cell[1] = div( 2 * g[1]+1 -  2*new_cell[1]-1 , 2) +1
                sym_cell[2] = div( 2 * g[2]+1 -  2*new_cell[2]-1 , 2) +1

                #Si la cellule est valide, on etend la galaxie a cette cellule et son symetrique et on cree une nouvelle instance
                if sym_cell[1]>0 && sym_cell[1]<= N[1] && sym_cell[2]>0 && sym_cell[2]<= N[2] && X[sym_cell[1],sym_cell[2]] == 0
                    isChild = true
                    cur.X[new_cell[1],new_cell[2]] = cur.X[cell[1],cell[2]]
                    cur.X[sym_cell[1],sym_cell[2]] = cur.X[cell[1],cell[2]]
                    push!(F,new_cell)
                    push!(F,sym_cell)
                    push!(stack,GalaxyToHeuristic(GalaxyInstance(cur.N,cur.X,cur.C),F))
                else
                    v += 1
                end
            end

            if v == n+1 #Dans ce cas, aucun voisin de la cellule consideree est valide, donc on ne peut pas etendre la galaxie a partir de cell
                deleteat!(F, j)
            end
        end

    end

    return false, time()-start
end

"""
Check if all the cells of the grid are assigned a galaxy
"""
function isFilled(inst::HeuristicInstance)
    X = inst.X
    N = inst.N

    for i in 1:N[1]
        for j in 1:N[2]
            if X[i,j]==0
                return false
            end
        end
    end

    return true
end

"""
Return the coordinates of the free neighbors (assigned 0) of the cell (i,j)
"""
function freeNeighbors(I,X, N)
    V = Vector{Vector{Int64}}(undef,0)
    i = I[1]
    j = I[2]
    if i-1>0 && X[i-1,j]==0
        push!(V,[i-1,j])
    end
    if i+1<=N[1] && X[i+1,j] ==0
        push!(V,[i+1,j])
    end
    if j-1>0 && X[i,j-1]==0
        push!(V,[i,j-1])
    end
    if j+1<=N[1] && X[i,j+1] ==0
        push!(V,[i,j+1])
    end
return V
end


"""
Solve all the instances contained in "../data" through CPLEX and heuristics

The results are written in "../res/cplex" and "../res/heuristic"

Remark: If an instance has previously been solved (either by cplex or the heuristic) it will not be solved again
"""
function solveDataSet()

    dataFolder = "../data/"
    resFolder = "../res/"

    # Array which contains the name of the resolution methods
    resolutionMethod = ["cplex"]
    # resolutionMethod = ["cplex", "heuristique"]

    # Array which contains the result folder of each resolution method
    resolutionFolder = resFolder .* resolutionMethod

    # Create each result folder if it does not exist
    for folder in resolutionFolder
        if !isdir(folder)
            mkdir(folder)
        end
    end

    global isOptimal = false
    global solveTime = -1

    # For each instance
    # (for each file in folder dataFolder which ends by ".txt")
    for file in filter(x->occursin(".txt", x), readdir(dataFolder))

        println("-- Resolution of ", file)
        readInputFile(dataFolder * file)

        # TODO
        println("In file resolution.jl, in method solveDataSet(), TODO: read value returned by readInputFile()")

        # For each resolution method
        for methodId in 1:size(resolutionMethod, 1)

            outputFile = resolutionFolder[methodId] * "/" * file

            # If the instance has not already been solved by this method
            if !isfile(outputFile)

                fout = open(outputFile, "w")

                resolutionTime = -1
                isOptimal = false

                # If the method is cplex
                if resolutionMethod[methodId] == "cplex"

                    # TODO
                    println("In file resolution.jl, in method solveDataSet(), TODO: fix cplexSolve() arguments and returned values")

                    # Solve it and get the results
                    isOptimal, resolutionTime = cplexSolve()

                    # If a solution is found, write it
                    if isOptimal
                        # TODO
                        println("In file resolution.jl, in method solveDataSet(), TODO: write cplex solution in fout")
                    end

                # If the method is one of the heuristics
                else

                    isSolved = false

                    # Start a chronometer
                    startingTime = time()

                    # While the grid is not solved and less than 100 seconds are elapsed
                    while !isOptimal && resolutionTime < 100

                        # TODO
                        println("In file resolution.jl, in method solveDataSet(), TODO: fix heuristicSolve() arguments and returned values")

                        # Solve it and get the results
                        isOptimal, resolutionTime = heuristicSolve()

                        # Stop the chronometer
                        resolutionTime = time() - startingTime

                    end

                    # Write the solution (if any)
                    if isOptimal

                        # TODO
                        println("In file resolution.jl, in method solveDataSet(), TODO: write the heuristic solution in fout")

                    end
                end

                println(fout, "solveTime = ", resolutionTime)
                println(fout, "isOptimal = ", isOptimal)

                # TODO
                println("In file resolution.jl, in method solveDataSet(), TODO: write the solution in fout")
                close(fout)
            end


            # Display the results obtained with the method on the current instance
            include(outputFile)
            println(resolutionMethod[methodId], " optimal: ", isOptimal)
            println(resolutionMethod[methodId], " time: " * string(round(solveTime, sigdigits = 2)) * "s\n")
        end
    end
end
