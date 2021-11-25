module MatrixOracle

include("oracle.jl")
include("equilibrium.jl")
include("matrix_oracle.jl")
include("iterators.jl")

export matrix_oracle
export fixed_iters
export until_eps

end