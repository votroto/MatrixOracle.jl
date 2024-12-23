"""
oracle(payoffs::NTuple{1}, strategies)

Best response oracle for two-player zero-sum games. Returns the best
the best responses and the corresponding payoffs.
"""
function oracle(payoffs::NTuple{1}, strategies)
    payoff = only(payoffs)
    oracle((payoff, -payoff), strategies)
end


"""
oracle(payoffs::NTuple, strategies)

Best response oracle for general matrix games.
"""
function oracle(
    payoffs::NTuple{N,AbstractArray{P}},
    strategies::NTuple{N, AbstractArray{S}}
) where {N, P, S}
    PS = promote_type(P, S)
    brfs = ntuple(p -> zeros(PS, length(strategies[p])), N)
    unilateral_payoffs!(brfs, payoffs, strategies)

    found_maxes = ntuple(i -> findmax(brfs[i]), N)
    xss = ntuple(i -> found_maxes[i][1], N)
    iss = ntuple(i -> found_maxes[i][2], N)

    xss, iss
end