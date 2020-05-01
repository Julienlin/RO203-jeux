# This file contains methods to generate a data set of instances (i.e., sudoku grids)
include("instance.jl")

"""
Generate an n1*n2 grid of game Galaxies

Argument
- n1: size of the grid
- n2: size of the grid
"""
function generateInstance(n1::Int64, n2::Int64)

    # TODO
    # println("In file generation.jl, in method generateInstance(), TODO: generate an instance")
    N = [n1,n2]
    X = zeros(Int64, N[1], N[2])
    C = Vector{Vector{Int64}}(undef, 0)
    F = Vector{Vector{Int64}}(undef, 0)

    is4Possible = true # Vrai s'il est toujours possible de rajouter un noyau de galaxie entre 4 cases
    isVPossible = true # Vrai s'il est toujours possible de rajouter un noyau de galaxie entre 2 cases sur un arete verticale
    isHPossible = true # Vrai s'il est toujours possible de rajouter un noyau de galaxie entre 2 cases sur un arete horizontale

    # On commence par generer un certain nombre de galaxies aleatoires

    G = div(n1 * n2, 16) # 16 est choisi a l'instinct
    g = 1
    while g <= G
        # On choisit aleatoirement les coordonnees du centre de la galaxie
        g_x, g_y = chooseGalaxyNode(N, X, is4Possible, isVPossible, isHPossible)

        # On choisit aleatoirement entre 10 et 20 le nombre de fois qu'on etend la galaxie
        extension = rand(4:7)

        # On construit la frontiere de la galaxie
        F, X = init_frontiere(X, g, g_x, g_y)

        # Ensuite on etend la galaxie
        e = 1
        while e <= extension && !isempty(F) && !isFilled(N, X)
            F, X, isChild = etendGalaxy(N, X, F, g, g_x, g_y)
            if isChild
                e += 1
            end

        end

        # Enfin on ajoute le noyau de la galaxie dans la liste
        push!(C, [g_x,g_y])
        g += 1

    end

    g -= 1
    # Ensuite on remplit le reste de la grille
    while !isFilled(N, X)

        g += 1
        g_x, g_y = chooseGalaxyNode(N, X, is4Possible, isVPossible, isHPossible)

        # Ensuite on calcule la frontiere de cette galaxie
        F, X = init_frontiere(X, g, g_x, g_y)

        # Ensuite on etend au maximum cette galaxie
        while !isempty(F)
            F, X, isChild = etendGalaxy(N, X, F, g, g_x, g_y)
        end

        # Enfin on ajoute le noyau de la galaxie dans la liste
        push!(C, [g_x,g_y])

    end
    return GalaxyInstance(N, X, C)
end


"""
Renvoie vrai si toutes les cases de la grille ont une galaxie attribuee, faux sinon
"""
function isFilled(N, X)
    for i in 1:N[1]
        for j in 1:N[2]
            if X[i,j] == 0
                return false
            end
        end
    end
    return true
end


"""
Renvoie la liste des cases non attribuees de la grille
"""
function emptyCells(N, X)
    E = Vector{Vector{Int64}}(undef, 0)
    for i in 1:N[1]
        for j in 1:N[2]
            if X[i,j] == 0
                push!(E, [i,j])
            end
        end
    end
    return E
end

"""
Renvoie un booleen disant s'il est possible de placer un noeud de galaxie au coin de quatre cases,
 ainsi que la liste des coordonnees de noyaux possibles (evt vide)
"""
function isAnglePossible(X_empty)
    isPossible = false
    Coords = Vector{Vector{Int64}}(undef, 0)

    for n in X_empty
        i = n[1]
        j = n[2]
        if ([i + 1,j] in X_empty) && ([i,j + 1] in X_empty) && ([i + 1,j + 1] in X_empty)
            push!(Coords, [2 * i,2 * j])
            isPossible = true
        end
    end
    return isPossible, Coords
end


"""
Renvoie un booleen disant s'il est possible de placer un noeud de galaxie sur un arete verticale entre 2 cases,
ainsi que la liste des coordonnees de noyaux possibles (evt vide)
"""
function isVerticalPossible(X_empty)
    isPossible = false
    Coords = Vector{Vector{Int64}}(undef, 0)

    for n in X_empty
        i = n[1]
        j = n[2]
        if [i,j + 1] in X_empty
            push!(Coords, [2 * i - 1,2 * j])
            isPossible = true
        end
    end
    return isPossible, Coords
end

"""
Renvoie un booleen disant s'il est possible de placer un noeud de galaxie sur un arete horizontale entre 2 cases,
 ainsi que la liste des coordonnees de noyaux possibles (evt vide)
"""
function isHorizontalPossible(X_empty)
    isPossible = false
    Coords = Vector{Vector{Int64}}(undef, 0)

    for n in X_empty
        i = n[1]
        j = n[2]
        if [i + 1,j] in X_empty
            push!(Coords, [2 * i,2 * j - 1])
            isPossible = true
        end
    end
    return isPossible, Coords
end


"""
Cree la frontiere de la galaxie autour de son noyau

Arguments :
 - X grille du jeu
 - g numero de la galaxie
 - g_x 1e coordonnee du noyau de la galaxie
 - g_y 2e coordonnee du noyau de la galaxie

Retourne
 - F frontiere de la galaxie
 - X grille modifiee
"""
function init_frontiere(X, g, g_x, g_y)
    F = Vector{Vector{Int64}}(undef, 0)

    if rem(g_x, 2) == 1 && rem(g_y, 2) == 1
        x = div(g_x, 2) + 1
        y = div(g_y, 2) + 1
        X[x,y] = g
        push!(F, [x,y])
        # Si le noyau est a cheval sur quatre cases
    elseif rem(g_x, 2) == 0 && rem(g_y, 2) == 0
        X[div(g_x - 1, 2) + 1 , div(g_y - 1, 2) + 1] = g
        X[div(g_x - 1, 2) + 1 , div(g_y + 1, 2) + 1] = g
        X[div(g_x + 1, 2) + 1 , div(g_y - 1, 2) + 1] = g
        X[div(g_x + 1, 2) + 1 , div(g_y + 1, 2) + 1] = g
        push!(F, [div(g_x - 1, 2) + 1,div(g_y - 1, 2) + 1], [div(g_x + 1, 2) + 1,div(g_y - 1, 2) + 1], [div(g_x - 1, 2) + 1,div(g_y + 1, 2) + 1], [div(g_x + 1, 2) + 1,div(g_y + 1, 2) + 1])
        # Si le noyau est a cheval entre deux cases, sur une ligne horizontale
    elseif rem(g_x, 2) == 0 && rem(g_y, 2) == 1
        X[div(g_x + 1, 2) + 1 , div(g_y, 2) + 1 ] = g
        X[div(g_x - 1, 2) + 1 , div(g_y, 2) + 1 ] = g
        push!(F, [div(g_x + 1, 2) + 1,div(g_y, 2) + 1], [div(g_x - 1, 2) + 1,div(g_y, 2) + 1])
        # Si le noyau est a cheval entre deux cases, sur une ligne verticale
    elseif rem(g_x, 2) == 1 && rem(g_y, 2) == 0
        X[div(g_x, 2) + 1 , div(g_y + 1, 2) + 1] = g
        X[div(g_x, 2) + 1 , div(g_y - 1, 2) + 1] = g
        push!(F,  [div(g_x, 2) + 1,div(g_y - 1, 2) + 1 ], [div(g_x, 2) + 1,div(g_y + 1, 2) + 1])
    end

    return F, X
end


function chooseGalaxyNode(N, X, is4Possible, isVPossible, isHPossible)
    # D'abord on doit choisir le centre de la nouvelle galaxie
    g_x = 0
    g_y = 0

    # On commence par tirer au sort le type de galaxie (centre sur un coin, un bord ou dans une case)
    r = rand()
    isNode = false # Vrai si on a trouve un noyau
    X_empty = emptyCells(N, X)
    if is4Possible && r < 0.25
        isPossible, A = isAnglePossible(X_empty)
        # S'il est possible de choisir un noyau au sur un coin entre 4 cases
        if isPossible
            isNode = true
            i = rand(1:size(A, 1))
            g_x = A[i][1]
            g_y = A[i][2]
        else
            is4Possible = false
        end
    end

    if !isNode && isVPossible && r < 0.5
        isPossible, A = isVerticalPossible(X_empty)
        # S'il est possible de choisir un noyau au sur un coin entre 4 cases
        if isPossible
            isNode = true
            i = rand(1:size(A, 1))
            g_x = A[i][1]
            g_y = A[i][2]
        else
            isVPossible = false
        end
    end

    if !isNode && isHPossible && r < 0.75
        isPossible, A = isHorizontalPossible(X_empty)
    # S'il est possible de choisir un noyau au sur un coin entre 4 cases
        if isPossible
            isNode = true
            i = rand(1:size(A, 1))
            g_x = A[i][1]
            g_y = A[i][2]
        else
            isHPossible = false
        end
    end

    if !isNode
        i = rand(1:size(X_empty, 1))
        g_x = 2 * X_empty[i][1] - 1
        g_y = 2 * X_empty[i][2] - 1
    end

    if g_x == 0 || g_y == 0
        println("Choix de centre de galaxie impossible !!!")
    end

    return g_x, g_y
end

"""
Etend la galaxie g a partir de sa frontiere

Arguments :
 - N taille de la grille
 - X grille
 - F frontiere de la galaxie a etendre
 - g numero de la galaxie
 - g_x 1e coordonnee du noyau de la galaxie
 - g_y 2e coordonnee du noyau de la galaxie

 Retourne
 - F frontiere modifiee
 - X grille modifiee
 - isChild booleen qui dit si la grille a effectivement pu etre etendue

"""

function etendGalaxy(N, X, F, g, g_x, g_y)

    # On choisit la case de frontiere que l'on veut etendre
    j = rand(1:size(F, 1))
    isCell = false
    # On cherche une cellule ayant un voisin encore non attribue
    while !isCell && !isempty(F)
        # Si la cellule n'a pas de voisin libre, on ne peut pas etendre de galaxie a partir d'elle, donc elle ne doit plus faire partie de la frontiere
        V = freeNeighbors(F[j][1], F[j][2], X, N)
        if isempty(V)
            deleteat!(F, j)
            if isempty(F)
                break
            end
            j = rand(1:size(F, 1))
        else
            isCell = true
        end
    end

    isChild = false

    if isempty(F)
        return F, X, false
    end

    cell = F[j]
    V = freeNeighbors(cell[1], cell[2], X, N)

    # Parmi les voisins, on en cherche un dont le symetrique par rapport au centre de la galaxie est aussi libre (et dans la grille)
    v = 1
    n = size(V, 1)
    while !isChild && v <= n

        # Calcul des coordonnees de la cellule symetrique
        new_cell = V[v]
        sym_cell = [0,0]
        sym_cell[1] = div(2 * g_x + 1 -  2 * new_cell[1] - 1, 2) + 1
        sym_cell[2] = div(2 * g_y + 1 -  2 * new_cell[2] - 1, 2) + 1

        # Si la cellule est valide, on etend la galaxie a cette cellule et son symetrique et on cree une nouvelle instance
        if sym_cell[1] > 0 && sym_cell[1] <= N[1] && sym_cell[2] > 0 && sym_cell[2] <= N[2] && X[sym_cell[1],sym_cell[2]] == 0
            isChild = true
            X[new_cell[1],new_cell[2]] = g
            X[sym_cell[1],sym_cell[2]] = g
            push!(F, new_cell)
            push!(F, sym_cell)
        else
            v += 1
        end
    end

    if v == n + 1 # Dans ce cas, aucun voisin de la cellule consideree est valide, donc on ne peut pas etendre la galaxie a partir de cell
        deleteat!(F, j)
    end

    return F, X, isChild

end

"""
Return the coordinates of the free neighbors (assigned 0) of the cell (i,j)
"""
function freeNeighbors(i, j, X, N)
    V = Vector{Vector{Int64}}(undef, 0)
    if i - 1 > 0 && X[i - 1,j] == 0
        push!(V, [i - 1,j])
    end
    if i + 1 <= N[1] && X[i + 1,j] == 0
        push!(V, [i + 1,j])
    end
    if j - 1 > 0 && X[i,j - 1] == 0
        push!(V, [i,j - 1])
    end
    if j + 1 <= N[1] && X[i,j + 1] == 0
        push!(V, [i,j + 1])
    end
    return V
end


"""
Generate all the instances

Remark: a grid is generated only if the corresponding output file does not already exist
"""
function generateDataSet()

    # TODO
    # println("In file generation.jl, in method generateDataSet(), TODO: generate an instance")

    path_to_dir = "../data/"
    path_to_sol = "../dataSol/"
    if !isdir(path_to_sol)
        mkdir(path_to_sol)
    end
    generic_filename = "instance_"

    for (n1, n2) in [(4, 4), (16, 16), (25, 25), (5, 13), (9, 10)]
        for num in 1:10
            inst_filename = path_to_dir * generic_filename * "size" * string(n1) * "_n" * string(num) * ".txt"
            sol_filename = path_to_sol * generic_filename * "size" * string(n1) * "_n" * string(num) * ".txt"
            if !isfile(inst_filename)
                inst = generateInstance(n1, n2)
                println("-- Generating file " * inst_filename)
                f_stream = open(inst_filename, "w")
                writeToFile(false, inst, f_stream)
                close(f_stream)
                f_stream = open(sol_filename, "w")
                writeToFile(true, inst, f_stream)
                close(f_stream)
            end
        end
    end
end
