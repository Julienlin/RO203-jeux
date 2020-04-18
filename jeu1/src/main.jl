include("io.jl")
include("resolution.jl")

function main()
    instance::UndeadInstance = readInputFile("./src/ex_instance.txt")
    displayGrid(instance)
    println(cplexSolve(instance))

end

main()