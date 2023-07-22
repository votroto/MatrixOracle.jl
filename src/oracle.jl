using SparseArrays

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
    players = eachindex(payoffs)
	pays = unilateral_payoffs(payoffs, strategies, players)
	unzip(findmax.(pays))
end

function worst(payoffs::NTuple, strategies)
    players = eachindex(payoffs)
	pays = unilateral_payoffs(payoffs, strategies, players)
	argmin.(pays)
end

function worst(payoffs::NTuple{1}, strategies)
	payoff = only(payoffs)
	worst((payoff, -payoff), strategies)
end