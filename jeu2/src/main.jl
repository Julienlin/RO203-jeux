include("instance.jl")
include("io.jl")
include("resolution.jl")

function main()
    instance = readInputFile("test.txt")
    displayGrid(instance)
    # isOptimal, resolutionTime = cplexSolve(instance)
    isOptimal, resolutionTime = heuristicSolve(instance)
    println(isOptimal, resolutionTime)
    displayGridSolution(instance)
    # file = open("testWrite.txt","w")
    # writeToFile(false,instance,file)
    # close(file)
end

main()