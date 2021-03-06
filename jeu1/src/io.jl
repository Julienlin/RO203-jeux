# This file contains functions related to reading, writing and displaying a grid and experimental results

using JuMP
using Plots
import GR

include("instance.jl")

"""
Read an instance from an input file

- Argument:
inputFile: path of the input file
"""
function readInputFile(inputFile::String)

    # Open the input file
    datafile = open(inputFile)

    data = readlines(datafile)

    # Remove comment lines from data
    filter!(el->strip(el)[1] != '#', data)
    close(datafile)

    # For each line of the input file


    # On the first line are the dimensions of the grid
    buf = split(data[1], ',')
    xN = parse(Int, buf[1])
    yN = parse(Int, buf[2])
    N = [xN,yN]


    # Parse G V and Z
    buf = split(data[2], '=')
    G = parse(Int, buf[2])

    buf = split(data[3], '=')
    V = parse(Int, buf[2])

    buf = split(data[4], '=')
    Z = parse(Int, buf[2])

    # Grid
    X = zeros(Int, N[1], N[2])
    for i in 5:(N[1] + 4)
        line = data[i]
        if N[2] != length(line)
            println("Problem of grid in input file")
        end
        for j in 1:N[2]
            if line[j] == '/'
                X[i - 4,j] = 4
            elseif line[j] == '\\'
                X[i - 4,j] = 5
            end
        end
    end

    # Parsing number of monsters for each path.
    Y = map(x->parse(Int64, x), split(data[N[1] + 5 ], ','))
    # Creating the paths of light in the grid
    if size(Y, 1) != 2 * (N[1] + N[2])
        println("Problem in the input file : wrong number of values")
    end
    C  = createPath(N, X)

    return UndeadInstance(N, X, Z, G, V, C, Y)
end

function createPath(N, X)
    C = Vector{Vector{Vector{Int64}}}(undef, 0)
    for i in 1:(2 * (N[1] + N[2])) # For each path in the grid
        c = Vector{Vector{Int64}}(undef, 0)

        # Direction of the light, coords of first cell
        if i <= N[2]
            direction = "down"
            x = 1 # number of line
            y = i # number of column
        elseif i <= N[1] + N[2]
            direction = "left"
            x = i - N[2]
            y = N[2]
        elseif i <= 2 * N[2] + N[1]
            direction = "up"
            x = N[1]
            # y = i - N[1] - N[2]
            y = 2 * N[2] + N[1] + 1 - i
        else
            direction = "right"
            # x = i - (2 * N[2])-1
            x = 2 * N[2] + 2 * N[1] + 1 - i
            y = 1
        end
        mirror = 1 # the visibility equals 1 before mirror, 0 after
        out = false # The path is to its end when the light gets out of the grid
        while !out
            if x < 1 || x > N[1] || y < 1 || y > N[2]
                out = true
            else
                # if there is a mirror, there is a change in direction
                if X[x, y] == 4 # '/'
                    mirror = 0
                    if direction == "down"
                        direction = "left"
                    elseif direction == "left"
                        direction = "down"
                    elseif direction == "up"
                        direction = "right"
                    elseif direction == "right"
                        direction = "up"
                    end
                elseif X[x, y] == 5 # '\'
                    mirror = 0
                    if direction == "down"
                        direction = "right"
                    elseif direction == "left"
                        direction = "up"
                    elseif direction == "up"
                        direction = "left"
                    elseif direction == "right"
                        direction = "down"
                    end
                        # if there is no mirror in the cell, the cell is added to the path
                else
                    push!(c, [x,y,mirror])
                end

                    # going to next cell
                if direction == "down"
                    x = x + 1
                elseif direction == "left"
                    y = y - 1
                elseif direction == "up"
                    x = x - 1
                elseif direction == "right"
                    y = y + 1
                end

            end
        end
        # Add the calculated path to C
        push!(C, c)
    end
    return C

end

"""
Write an instance of the game in a given file
Arguments :
    - path::String : path to file where we write
    - ins::UndeadInstance : instance of the game
"""
function writeToFile(isSolution::Bool, inst::UndeadInstance, file::IOStream)
    write(file, "# Dimensions de la grille :")
    write(file, "\n")
    write(file, string(inst.N[1]), ",", string(inst.N[2]))
    write(file, "\n")
    write(file, "# Totaux des monstres :")
    write(file, "\n")
    write(file, "G=", string(inst.G))
    write(file, "\n")
    write(file, "V=", string(inst.V))
    write(file, "\n")
    write(file, "Z=", string(inst.Z))
    write(file, "\n")
    write(file, "# Grille :")
    write(file, "\n")
    for i in 1:inst.N[1]
        for j in 1:inst.N[2]
            if inst.X[i,j] == 0
                write(file, "-")
            elseif inst.X[i,j] == 4
                write(file, '/')
            elseif inst.X[i,j] == 5
                write(file, '\\')
            else
                if isSolution
                    if inst.X[i,j] == 1
                        write(file, "G")
                    elseif inst.X[i,j] == 2
                        write(file, "Z")
                    elseif inst.X[i,j] == 3
                        write(file, "V")
                    end
                else
                    write(file, "-")
                end
            end
        end
        write(file, "\n")
    end
    write(file, "# Valeur des chemins (sens horaire a partir d en haut a gauche)")
    write(file, "\n")
    for i in 1:size(inst.Y, 1) - 1
        write(file, string(inst.Y[i]), ",")
    end
    write(file, string(inst.Y[size(inst.Y, 1)]), "\n")
end

"""
Print in terminal the grid of the problem
Arguments :
- instance of the problem
"""
function displayGrid(instance::UndeadInstance)
    println("###########################################################")
    println("                   Game Undead : Grid")
    println("###########################################################")
    println("")

    # print total numbers of monsters
    print("Ghosts : ")
    println(instance.G)
    print("Vampires : ")
    println(instance.V)
    print("Zombies : ")
    println(instance.Z)

    println("")
    print(" ")
    Y = instance.Y
    X = instance.X
    N = instance.N
    # Print values of paths beginning on the top
    for i in 1:N[2]
        print(" ")
        print(Y[i])
    end
    println("")
    for i in 1:N[1]
        indice = 2 * (N[1] + N[2]) - i + 1
        print(Y[indice]) # Print value of path beginning on the left
        # Print line of grid
        for j in 1:N[2]
            print(" ")
            if X[i,j] == 4
                print("/")
            elseif X[i,j] == 5
                print("\\")
            else
                print(" ")
            end
        end
        print(" ")
        println(Y[N[2] + i]) # Print value of path beginning on the right
    end
    # Print values of paths beginning from the bottom
    print(" ")
    for i in 1:N[2]
        print(" ")
        ind = N[1] + 2 * N[2] - i + 1
        print(Y[ind])
    end
    println("")
end

"""
Print in terminal the solution of the problem
Arguments :
- instance of the problem
"""
function displaySolution(instance, log = stdout)
    println(log, "###########################################################")
    println(log, "                   Game Undead : Solution")
    println(log, "###########################################################")
    println(log, "")

    # print total numbers of monsters
    print(log, "Ghosts : ")
    println(log, instance.G)
    print(log, "Vampires : ")
    println(log, instance.V)
    print(log, "Zombies : ")
    println(log, instance.Z)

    println(log, "")
    print(log, " ")
    Y = instance.Y
    X = instance.X
    N = instance.N
    # Print values of paths beginning on the top
    for i in 1:N[2]
        print(log, " ")
        print(log, Y[i])
    end
    println(log, "")
    for i in 1:N[1]
        indice = 2 * (N[1] + N[2]) - i + 1
        print(log, Y[indice]) # Print value of path beginning on the left
        # Print line of grid
        for j in 1:N[2]
            print(log, " ")
            if X[i,j] == 1
                print(log, "G")
            elseif X[i,j] == 2
                print(log, "Z")
            elseif X[i,j] == 3
                print(log, "V")
            elseif X[i,j] == 4
                print(log, "/")
            elseif X[i,j] == 5
                print(log, "\\")
            else
                print(log, " ")
            end
        end
        print(log, " ")
        println(log, Y[N[2] + i]) # Print value of path beginning on the right
    end
    # Print values of paths beginning from the bottom
    print(log, " ")
    for i in 1:N[2]
        print(log, " ")
        ind = N[1] + 2 * N[2] - i + 1
        print(log, Y[ind])
    end
    println(log, "")
end

"""
Create a pdf file which contains a performance diagram associated to the results of the ../res folder
Display one curve for each subfolder of the ../res folder.

Arguments
- outputFile: path of the output file

Prerequisites:
- Each subfolder must contain text files
- Each text file correspond to the resolution of one instance
- Each text file contains a variable "solveTime" and a variable "isOptimal"
"""
function performanceDiagram(outputFile::String)

    resultFolder = "../res/"

    # Maximal number of files in a subfolder
    maxSize = 0

    # Number of subfolders
    subfolderCount = 0

    folderName = Array{String,1}()

    # For each file in the result folder
    for file in readdir(resultFolder)

        path = resultFolder * file

    # If it is a subfolder
        if isdir(path)

            folderName = vcat(folderName, file)

            subfolderCount += 1
            folderSize = size(readdir(path), 1)

            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Array that will contain the resolution times (one line for each subfolder)
    results = Array{Float64}(undef, subfolderCount, maxSize)

    for i in 1:subfolderCount
        for j in 1:maxSize
            results[i, j] = Inf
        end
    end

    folderCount = 0
    maxSolveTime = 0

    # For each subfolder
    for file in readdir(resultFolder)

        path = resultFolder * file
        println("path = $path")

        if isdir(path)

            folderCount += 1
            fileCount = 0

    # For each text file in the subfolder
            for resultFile in filter(x->occursin(".txt", x), readdir(path))

                fileCount += 1
                include(path * "/" * resultFile)

                if isOptimal
                    results[folderCount, fileCount] = solveTime

                    if solveTime > maxSolveTime
                        maxSolveTime = solveTime
                    end
                end
            end
        end
    end

    # Sort each row increasingly
    results = sort(results, dims = 2)

    println("Max solve time: ", maxSolveTime)

    # For each line to plot
    for dim in 1:size(results, 1)

        x = Array{Float64,1}()
        y = Array{Float64,1}()

    # x coordinate of the previous inflexion point
        previousX = 0
        previousY = 0

        append!(x, previousX)
        append!(y, previousY)

    # Current position in the line
        currentId = 1

    # While the end of the line is not reached
        while currentId != size(results, 2) && results[dim, currentId] != Inf

    # Number of elements which have the value previousX
            identicalValues = 1

        # While the value is the same
            while results[dim, currentId] == previousX && currentId <= size(results, 2)
                currentId += 1
                identicalValues += 1
            end

    # Add the proper points
            append!(x, previousX)
            append!(y, currentId - 1)

            if results[dim, currentId] != Inf
                append!(x, results[dim, currentId])
                append!(y, currentId - 1)
            end

            previousX = results[dim, currentId]
            previousY = currentId - 1

        end

        append!(x, maxSolveTime)
        append!(y, currentId - 1)

    # If it is the first subfolder
        if dim == 1

    # Draw a new plot
            plot(x, y, label = folderName[dim], legend = :bottomright, xaxis = "Time (s)", yaxis = "Solved instances", linewidth = 3)
            savefig(outputFile)
            # savefig(plot!(x, y, label = folderName[dim], linewidth = 3), outputFile)

    # Otherwise
        else
    # Add the new curve to the created plot
            savefig(plot!(x, y, label = folderName[dim], linewidth = 3), outputFile)
        end
    end
end

"""
Create a latex file which contains an array with the results of the ../res folder.
Each subfolder of the ../res folder contains the results of a resolution method.

Arguments
- outputFile: path of the output file

Prerequisites:
- Each subfolder must contain text files
- Each text file correspond to the resolution of one instance
- Each text file contains a variable "solveTime" and a variable "isOptimal"
"""
function resultsArray(outputFile::String)

    resultFolder = "../res/"
    dataFolder = "../data/"

    # Maximal number of files in a subfolder
    maxSize = 0

    # Number of subfolders
    subfolderCount = 0

    # Open the latex output file
    fout = open(outputFile, "w")

    # Print the latex file output
    println(fout, raw"""\documentclass{article}

\usepackage[french]{babel}
\usepackage [utf8] {inputenc} % utf-8 / latin1
\usepackage{multicol}

\setlength{\hoffset}{-18pt}
\setlength{\oddsidemargin}{0pt} % Marge gauche sur pages impaires
\setlength{\evensidemargin}{9pt} % Marge gauche sur pages paires
\setlength{\marginparwidth}{54pt} % Largeur de note dans la marge
\setlength{\textwidth}{481pt} % Largeur de la zone de texte (17cm)
\setlength{\voffset}{-18pt} % Bon pour DOS
\setlength{\marginparsep}{7pt} % Séparation de la marge
\setlength{\topmargin}{0pt} % Pas de marge en haut
\setlength{\headheight}{13pt} % Haut de page
\setlength{\headsep}{10pt} % Entre le haut de page et le texte
\setlength{\footskip}{27pt} % Bas de page + séparation
\setlength{\textheight}{668pt} % Hauteur de la zone de texte (25cm)

\begin{document}""")

    header = raw"""
\begin{center}
\renewcommand{\arraystretch}{1.4}
\begin{tabular}{l"""

    # Name of the subfolder of the result folder (i.e, the resolution methods used)
    folderName = Array{String,1}()

    # List of all the instances solved by at least one resolution method
    solvedInstances = Array{String,1}()

    # For each file in the result folder
    for file in readdir(resultFolder)

        path = resultFolder * file

    # If it is a subfolder
        if isdir(path)

    # Add its name to the folder list
            folderName = vcat(folderName, file)

            subfolderCount += 1
            folderSize = size(readdir(path), 1)

    # Add all its files in the solvedInstances array
            for file2 in filter(x->occursin(".txt", x), readdir(path))
                solvedInstances = vcat(solvedInstances, file2)
            end

            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Only keep one string for each instance solved
    unique(solvedInstances)

    # For each resolution method, add two columns in the array
    for folder in folderName
        header *= "rr"
    end

    header *= "}\n\t\\hline\n"

    # Create the header line which contains the methods name
    for folder in folderName
        header *= " & \\multicolumn{2}{c}{\\textbf{" * folder * "}}"
    end

    header *= "\\\\\n\\textbf{Instance} "

    # Create the second header line with the content of the result columns
    for folder in folderName
        header *= " & \\textbf{Temps (s)} & \\textbf{Optimal ?} "
    end

    header *= "\\\\\\hline\n"

    footer = raw"""\hline\end{tabular}
\end{center}

"""
    println(fout, header)

    # On each page an array will contain at most maxInstancePerPage lines with results
    maxInstancePerPage = 30
    id = 1

    # For each solved files
    for solvedInstance in solvedInstances

    # If we do not start a new array on a new page
        if rem(id, maxInstancePerPage) == 0
            println(fout, footer, "\\newpage")
            println(fout, header)
        end

    # Replace the potential underscores '_' in file names
        print(fout, replace(solvedInstance, "_" => "\\_"))

    # For each resolution method
        for method in folderName

            path = resultFolder * method * "/" * solvedInstance

    # If the instance has been solved by this method
            if isfile(path)

                include(path)

                println(fout, " & ", round(solveTime, digits = 2), " & ")

                if isOptimal
                    println(fout, "\$\\times\$")
                end

    # If the instance has not been solved by this method
            else
                println(fout, " & - & - ")
            end
        end

        println(fout, "\\\\")

        id += 1
    end

    # Print the end of the latex file
    println(fout, footer)

    println(fout, "\\end{document}")

    close(fout)

end
