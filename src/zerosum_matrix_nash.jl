using JuMP

# SCIP does not solve for duals :(
function _nash_equilibrium_simple(payoffs::NTuple{1}; optimizer=_DEFAULT_OPTIMIZER)
    payoff = only(payoffs)
    axis = axes(payoff, 1)

    model = Model(optimizer)
    @variable model v
    @variable model weight[axis] >= 0
    @objective model Min v
    c = @constraint model v .>= -payoff' * weight
    @constraint model sum(weight) == 1

    optimize!(model)

    -value(v), value.(weight)
end

"""
    nash_equilibrium(payoffs::NTuple{1}; optimizer=_default_optimizer())

Compute the nash equilibrium for a two-player zero-sum game.
"""
function nash_equilibrium(payoffs::NTuple{1})
    P = only(payoffs)

	v1, s1 = _nash_equilibrium_simple((P,))
	v2, s2 = _nash_equilibrium_simple((-transpose(P),))
    
    [v1, v2], [s1, s2]
end
