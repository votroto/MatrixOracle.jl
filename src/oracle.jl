# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x -> getfield.(a, x), fieldnames(eltype(a)))


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