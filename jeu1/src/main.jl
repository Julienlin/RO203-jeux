include("io.jl")
include("resolution.jl")
include("generation.jl")

function main()
    # instance::UndeadInstance = readInputFile("ex_instance_full_zombies.txt")
    # instance::UndeadInstance = readInputFile("ex_instance_full_zombies_one_mirror.txt")
    # instance::UndeadInstance = readInputFile("../data/instance_n4_9.txt")
    # heuristicSolve(instance)
    # displayGrid(instance)
    # println(cplexSolve(instance))
    # displaySolution(instance)
    # writeToFile(instance,"test_writing.txt")
    # generateDataSet()

    # log= open("result.txt", "w")
    solveDataSet()
    # close(log)
    resultsArray("resultFile.tex")
    performanceDiagram("performanceDiagram")
    # is_feasable, t = heuristicSolve(instance)
end

main()
