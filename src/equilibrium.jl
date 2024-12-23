"""
unilateral_payoffs(payoffs::NTuple, strategies::NTuple; players)

Computes the payoffs that each player could get by unilateral deviation.
"""
function unilateral_payoffs!(
    result::NTuple{N},
    payoffs::NTuple{N},
    strategies::NTuple{N};
    players=eachindex(payoffs)
) where {N}
    for p in players
        for i in CartesianIndices(payoffs[p])
            temp = payoffs[p][i]
            for z in players
                if z == p
                    continue
                end
                temp *= strategies[z][i.I[z]]
            end
            result[p][i.I[p]] += temp
        end
    end
    result
end


"""
    _subgames(payoffs, actions)

Construct subgames restricted to actions.
"""
_subgames(payoffs, actions) = map(p -> view(p, actions...), payoffs)


"""
    equilibrium(payoffs, actions)

Compute the player equilibrium strategies in a subgame restricted to actions.
"""
function equilibrium(payoffs, actions)
    subproblem = _subgames(payoffs, actions)
    vals, probs = nash_equilibrium(subproblem)
    vals, sparsevec.(actions, probs, size(first(payoffs)))
end