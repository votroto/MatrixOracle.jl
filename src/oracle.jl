using SparseArrays
using LinearAlgebra: rank

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
function oracle(payoffs::NTuple, strategies)
    pays = unilateral_payoffs(payoffs, strategies)
    unzip(findmax.(pays))
end

"""
Keeps only up to the best `rank + 1` supports ordered by the response functions.
"""
function prune_support(payoffs::NTuple, strategies, pures)
    topn(p, r) = collect(Iterators.take(reverse(sortperm(p)), r + 1))

    rnk = rank.(payoffs)
    pays = unilateral_payoffs(payoffs, strategies)
    [pures[i][topn(pays[i][pures[i]], rnk[i])] for i in eachindex(pays)]
end

function prune_support(payoffs::NTuple{1}, strategies, pures)
    payoff = only(payoffs)
    prune_support((payoff, -payoff), strategies, pures)
end