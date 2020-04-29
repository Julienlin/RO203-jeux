# This file contains methods to generate a data set of instances (i.e., sudoku grids)
include("io.jl")

"""
Generate an n*n grid with a given density

Argument
- n1: size of the grid
- n2: size of the grid
"""
function generateInstance(n1::Int64, n2::Int64)

    # TODO
    # println("In file generation.jl, in method generateInstance(), TODO: generate an instance")
    N = [n1,n2]
    X = zeros(Int64, n,n)
    C = Vector{Vector{Int64}}(undef, 0)
    F = Vector{Vector{Int64}}(undef, 0)

    #On commence par generer un certain nombre de galaxies aleatoires
    G = div(n1*n2,64) +1 #64 est choisi a l'instinct
    for g in 1:G
        #On choisit aleatoirement les coordonnees du centre de la galaxie
        g_x = rem(rand()*(2*n1)+1,1)
        g_y = rem(rand()*(2*n2)+1,1)
        #On choisit aleatoirement entre 10 et 20 le nombre de fois qu'on etend la galaxie
        extension = rem(rand()*10 +10 ,1)

        #On construit la frontiere de la galaxie
        F = Vector{Vector{Int64}}(undef, 0)
        if rem(g_x,2)==1 && rem(g_y,2)==1
            x =div(g_x,2)+1
            y = div(g_y,2)+1
            X[x,y] = i
            push!(F,[x,y])
        #Si le noyau est a cheval sur quatre cases
        elseif rem(g_x,2)==0 && rem(g_y,2)==0
            X[div(g_x-1,2)+1 , div(g_y-1,2)+1] = i
            X[div(g_x-1,2)+1 , div(g_y+1,2)+1] = i
            X[div(g_x+1,2)+1 , div(g_y-1,2)+1] = i
            X[div(g_x+1,2)+1 , div(g_y+1,2)+1] = i
            push!(F, [div(g_x-1,2)+1,div(g_y-1,2)+1] , [div(g_x+1,2)+1,div(g_y-1,2)+1] , [div(g_x-1,2)+1,div(g_y+1,2)+1] , [div(g_x+1,2)+1,div(g_y+1,2)+1] )
       #Si le noyau est a cheval entre deux cases, sur une ligne horizontale
        elseif rem(g_x,2)==0 && rem(g_y,2)==1
            X[div(g_x+1,2)+1 , div(g_y,2)+1 ] = i
            X[div(g_x-1,2)+1 , div(g_y,2)+1 ] = i
            push!(F, [div(g_x+1,2)+1,div(g_y,2)+1] , [div(g_x-1,2)+1,div(g_y,2)+1] )
        #Si le noyau est a cheval entre deux cases, sur une ligne verticale
        elseif rem(g_x,2)==1 && rem(g_y,2)==0
            X[div(g_x,2)+1 , div(g_y+1,2)+1] = i
            X[div(g_x,2)+1 , div(g_y-1,2)+1] = i
            push!(F,  [div(g_x,2)+1,div(g_y-1,2)+1 ] , [div(g_x,2)+1,div(g_y+1,2)+1] )
        end



    end

    while !isFilled(X)
        g
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
    # println("In file generation.jl, in method generateDataSet(), TODO: generate an instance")

    path_to_dir = "../data/"
    generic_filename = "instance_"

    for (n1,n2) in [(4,4), (16,16), (25,25), (5,13), (9, 10)]
        for num in 1:10
            inst = generateInstance(n1,n2)
            inst_filename = path_to_dir * generic_filename * "n_" * string(num) * " .txt"
            if !isfile(inst_filename)
                println("-- Generating file " * inst_filename)
                f_stream = open(inst_filename, "w")
                writeToFile(false, inst, f_stream)
                close(f_stream)
            end
        end
    end
end



