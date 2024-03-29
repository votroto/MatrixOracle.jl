# Matrix Oracle (Experimental)
A proof of concept generalization of the Double Oracle algorithm to solving
matrix games -- including multiplayer general-sum games.

Player `i` chooses strategies on the `i`-th axis of the payoff matrix.

```julia
p = rand(5, 4)

# Solve a two-player zero-sum game using 10 iterations.
(strats, vals, subopt) = fixed_iters(matrix_oracle((p,)), 10)

# Ditto with a starting point (player 2 starts with cols 1 and 3).
(strats, vals, subopt) = fixed_iters(matrix_oracle((p,); init=([5], [1,3])), 10)

# Stops once it finds an ε-equilibrium.
iters, (strats, vals, subopt) = until_eps(matrix_oracle((p,)), 1e-3)
```

You can also try solving multiplayer general-sum games
```julia
A = [9 0; 0 9;;; 0 3; 3 0]
B = [8 0; 0 8;;; 0 4; 4 0]
C = [12 0; 0 2;;; 0 6; 6 0]

iters, (strats, vals, subopt) = until_eps(matrix_oracle((A, B, C)), 1e-3)

```
