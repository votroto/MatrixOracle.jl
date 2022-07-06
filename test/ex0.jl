using MatrixOracle
using Random

Random.seed!(1245)

P = [0 1; 1 0]

strategies, vals, best = fixed_iters(matrix_oracle((P,)), 4)
