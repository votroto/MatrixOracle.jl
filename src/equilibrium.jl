using MosekTools
using JuMP

function default_optimizer()
	attributes = [
		"MSK_IPAR_NUM_THREADS" => 1,
		"QUIET" => true
	]
	optimizer_with_attributes(Mosek.Optimizer, attributes...)
end

subgame(payoff, pures) = view(payoff, pures...)

function nash_equilibrium(payoff::AbstractMatrix; optimizer=default_optimizer())
	axis = axes(payoff, 1)

	model = Model(optimizer)
	@variable model v
	@variable model weight[axis] >= 0
	@objective model Min v
	c = @constraint model v .>= -payoff' * weight
	@constraint model sum(weight) == 1

	optimize!(model)

	[-value(v), value(v)], [value.(weight), dual.(c)]
end

function equilibrium(payoffs, pures)
	subproblem = subgame(payoffs, pures)
	vals, probs = nash_equilibrium(subproblem)
	vals, sparsevec.(pures, probs, size(payoffs))
end