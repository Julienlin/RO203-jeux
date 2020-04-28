# This file contains methods to generate a data set of instances (i.e., sudoku grids)
include("io.jl")

"""
Generate an n*n grid with a given density

Argument
- n: size of the grid
"""
function generateInstance(n::Int64)

    # TODO
    # println("In file generation.jl, in method generateInstance(), TODO: generate an instance")
    N = [n,n]
    X = zeros(Int64, n,n)
    C = Vector{Vector{Int64}}(undef, 0)

    while !isFilled(X)

    end
end

function isFilled(X::Array{Int64,2})
    return all(map(x -> x != 0, X))
end

"""
Generate all the instances

Remark: a grid is generated only if the corresponding output file does not already exist
"""
function generateDataSet()

    # TODO
    println("In file generation.jl, in method generateDataSet(), TODO: generate an instance")

end



