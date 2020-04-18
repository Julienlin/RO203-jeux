include("io.jl")
include("resolution.jl")

function main()
    instance::UndeadInstance = readInputFile("ex_instance_full_zombies_one_mirror.txt")
    displayGrid(instance)
    println(cplexSolve(instance))
    displaySolution(instance)

end

main()
