include("instance.jl")
include("io.jl")
include("generation.jl")
include("resolution.jl")

function main()
    
    
    # instance = readInputFile("../data/instance_size6_n5.txt")
    # displayGrid(instance)
    # # isOptimal, resolutionTime = cplexSolve(instance)
    # isOptimal, resolutionTime = heuristicSolve(instance)
    # println("$isOptimal $resolutionTime")
    # displayGridSolution(instance)
    # file = open("testWrite.txt","w")
    # writeToFile(false,instance,file)
    # close(file)

    # instance = generateInstance(7, 7)
    # println(" C = $(instance.C)")
    # displayGridSolution(instance)

    # generateDataSet()
    solveDataSet()
    performanceDiagram("performanceDiagram.png")
    resultsArray("resultFile.tex")

    # instance = readInputFile("../data/instance_size6_n4.txt")
    # heuristicSolve(instance)
end

main()
