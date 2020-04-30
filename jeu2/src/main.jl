include("instance.jl")
include("io.jl")
include("generation.jl")
# include("resolution.jl")

function main()
    # instance = readInputFile("test.txt")
    # displayGrid(instance)
    # # isOptimal, resolutionTime = cplexSolve(instance)
    # isOptimal, resolutionTime = heuristicSolve(instance)
    # println("$isOptimal $resolutionTime")
    # displayGridSolution(instance)
    # file = open("testWrite.txt","w")
    # writeToFile(false,instance,file)
    # close(file)

    instance = generateInstance(7, 7)
    println(" C = $(instance.C)")
    displayGridSolution(instance)
end

main()