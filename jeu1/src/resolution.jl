# This file contains methods to solve an instance (heuristically or with CPLEX)
using CPLEX
using JuMP

include("generation.jl")

TOL = 0.00001

"""
Solve an instance with CPLEX
"""
function cplexSolve(inst::UndeadInstance)

    N = inst.N
    Z = inst.Z
    G = inst.G
    V = inst.V
    Y = inst.Y


    # Create the model
    m = Model(CPLEX.Optimizer)

    # TODO
    println("In file resolution.jl, in method cplexSolve(), TODO: fix input and output, define the model")

    # Declare the variable
    @variable(m, x[1:N[1], 1:N[2], 1:5], Bin)

    # Declare the constraints

    ## Constraint on mirrors place on the grid

    for i in 1:N[1]
        for j in 1:N[2]
            if inst.X[i,j] == 4 || inst.X[i,j] == 5
                @constraint(m, x[i,j,inst.X[i,j]] == 1)
            end
        end
    end

    # @constraint(m,[ i in 1:N[1], j in 1:N[2]; inst.X[i,j] == 4 || inst.X[i,j] == 5 ], x[i,j,inst.X[i,j]] == 1)



    ## Constraint on unicity of the type of box
    ## TODO: A verifier
    @constraint(m, [i = 1:N[1], j = 1:N[2]], sum(x[i,j,k] for k in 1:5) == 1)

    ## Constraint on number of monsters per type
    @constraint(m, sum(x[i,j, 1] for i in 1:N[1], j in 1:N[2]) == G)
    @constraint(m, sum(x[i,j, 2] for i in 1:N[1], j in 1:N[2]) == Z)
    @constraint(m, sum(x[i,j, 3] for i in 1:N[1], j in 1:N[2]) == V)

    ## Constraint on number of monsters per path
    @constraint(m, [c = 1:size(inst.C, 1)], sum(x[ inst.C[c][1], inst.C[c][2], 2 ]) # number of zombies on the path
                                            + sum(x[ inst.C[c][1], inst.C[c][2], 3 ] * inst.C[c][3]) # number of vampires on the path
                                            + sum(x[inst.C[c][1], inst.C[c][2], 1] * (1 - inst.C[c][3])) # number of ghosts on the path
                                            == Y[c] )

    # Start a chronometer
    start = time()

    # Solve the model
    optimize!(m)

    # Return:
    # 1 - true if an optimum is found
    # 2 - the resolution time
    return JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT, time() - start

end

"""
Heuristically solve an instance
"""
function heuristicSolve()

    # TODO
    println("In file resolution.jl, in method heuristicSolve(), TODO: fix input and output, define the model")

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
