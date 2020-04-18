Pour utiliser ce programme, se placer dans le répertoire ./src

Les utilisations possibles sont les suivantes :

I - Génération d'un jeu de données
julia
include("generation.jl")
generateDataSet()

II - Résolution du jeu de données
julia
include("resolution.jl")
solveDataSet()

III - Présentation des résultats sous la forme d'un diagramme de performances
julia
include("io.jl")
performanceDiagram("../res/diagramme.pdf")

Définition du standard de lecture : (exemple de l'énoncé)
Dimensions de la grille :
4,4
Totaux des monstres :
G=3
V=4
Z=4
Grille :
/-\-
-/--
--/\
----
Valeur des chemins (sens horaire à partir d'en haut à gauche)
0,0,1,1,0,3,2,3,4,3,2,2,3,4,2,0

IV - Présentation des résultats sous la forme d'un tableau
julia
include("io.jl")
resultsArray("../res/array.tex")
