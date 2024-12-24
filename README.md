# Matrix Oracle
Generalized Double Oracle algorithm for finding epsilon-Nash-equilibria of multiplayer strategic games.

Actions available to player `i` correspond to the indices along the `i`-th axis of the payoff tensor.

## Zero-Sum Games
Specify a single matrix to treat the game as zero-sum.
```julia
p = rand(5, 4)

# Stops once it finds an ε-equilibrium.
iters, (strats, vals, incentive) = until_eps(matrix_oracle((p,)), 1e-3)
```
You can also set a starting point, or limit the number of iterations

```julia
# Solve a two-player zero-sum game using 10 iterations.
(strats, vals, incentive) = fixed_iters(matrix_oracle((p,)), 10)

# Ditto with a starting point (player 2 starts with cols 1 and 3).
(strats, vals, incentive) = fixed_iters(matrix_oracle((p,); init=([5], [1,3])), 10)
```

## General-Sum Games
Bimatrix games can be specified analogously
```julia
p1 = [2 0; 3 1]
p2 = [2 3; 0 1]

iters, (strats, vals, incentive) = until_eps(matrix_oracle((p1, p2)), 1e-3)
```

and multiplayer general-sum games are possible, as well:
```julia
A = [9 0; 0 9;;; 0 3; 3 0]
B = [8 0; 0 8;;; 0 4; 4 0]
C = [12 0; 0 2;;; 0 6; 6 0]

iters, (strats, vals, incentive) = until_eps(matrix_oracle((A, B, C)), 1e-3)

```
