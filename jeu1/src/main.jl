include("io.jl")
include("resolution.jl")
include("generation.jl")

function main()
    # instance::UndeadInstance = readInputFile("ex_instance_simple2.txt")
    # instance::UndeadInstance = readInputFile("ex_instance_full_zombies_one_mirror.txt")
    # instance::UndeadInstance = readInputFile("ex_instance_full_zombies.txt")
    # displayGrid(instance)
    # println(cplexSolve(instance))
    # displaySolution(instance)
    # writeToFile(instance,"test_writing.txt")
    generateDataSet()
    solveDataSet()

end

main()
