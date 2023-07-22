module MatrixOracle

include("utils.jl")
include("oracle.jl")
include("equilibrium.jl")
include("matrix_oracle.jl")
include("zerosum_matrix_nash.jl")
include("jump_extensions.jl")
include("multilinear_matrix_nash.jl")
include("iterators.jl")

export matrix_oracle
export fixed_iters
export until_eps

end