using Gurobi
using JuMP

"""
    nash_equilibrium(payoffs::NTuple{1}; optimizer=_default_optimizer())

Compute the nash equilibrium for a two-player zero-sum game.
"""
function nash_equilibrium(payoffs::NTuple{1}; optimizer=_DEFAULT_OPTIMIZER)
	payoff = only(payoffs)
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
