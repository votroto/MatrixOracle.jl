using MatrixOracle
using Random

Random.seed!(1245)

A = randn(3,3,3)
B = randn(3,3,3)
C = randn(3,3,3)

cnt, (strategies, vals, best) = until_eps(matrix_oracle((A, B, C)), 1e-3)
