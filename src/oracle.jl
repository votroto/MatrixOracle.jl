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

function oracle(
    payoffs::NTuple{1,AbstractArray},
    strategies::NTuple{2,AbstractArray}
)
    max1, act1 = findmax(payoffs[1] * strategies[2])
    min2, act2 = findmin(payoffs[1]' * strategies[1])

    (max1, -min2), (act1, act2)
end