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