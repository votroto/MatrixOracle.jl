using MosekTools
using JuMP

subgame(payoffs, pures) = map(p -> view(p, pures...), payoffs)

function equilibrium(payoffs, pures)
	subproblem = subgame(payoffs, pures)
	vals, probs = nash_equilibrium(subproblem)
	vals, sparsevec.(pures, probs, size(first(payoffs)))
end