PLAYER 1 picks the ROWS to MAXIMIZE his PAYOFF

```
p = [
	-1.11543   -0.909192   1.35002    0.555233
	0.266551  -0.899694  -1.15107   -2.25091
	0.170786   0.577513  -1.30527   -1.47238
	0.133098   1.19972   -0.29065    0.353489
   -0.143393   0.39024   -0.813464   0.95404
]

# either fixed number of iterations
(strategies, vals, best) = fixed_iters(matrix_oracle(p), 10)

# can also provide a starting point (column player starts with cols 1 and 3)
(strategies, vals, best) = fixed_iters(matrix_oracle(p; init=([5], [1,3])), 10)

# or until ε-equilibrium
cnt, (strategies, vals, best) = until_eps(matrix_oracle(p), 1e-3)

@show cnt

@show strategies[1]
@show strategies[2]
@show vals[1]
@show vals[2]
@show best[1]
@show best[2]
```
