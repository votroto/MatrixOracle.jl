"""
oracle(payoffs, strategies)

Best response oracle for strategic games. Returns the best payoffs and the
pure actions that achieve them.
"""
function oracle(
    payoffs::NTuple{N,AbstractArray{P}},
    strategies::NTuple{N,AbstractArray{S}}
) where {N,P,S}
    PS = promote_type(P, S)
    brfs = ntuple(p -> zeros(PS, length(strategies[p])), N)
    unilateral_payoffs!(brfs, payoffs, strategies)

    found_maxes = ntuple(i -> findmax(brfs[i]), N)
    maxes = ntuple(i -> found_maxes[i][1], N)
    acts = ntuple(i -> found_maxes[i][2], N)

    maxes, acts
end

function oracle(payoffs::NTuple{1}, strategies)
    payoff = only(payoffs)
    oracle((payoff, -payoff), strategies)
end