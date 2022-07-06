using SparseArrays

function oracle(payoffs::NTuple{1}, strategies)
	payoff = only(payoffs)
	ps = (payoff, -payoff')

	es = ps .* reverse(strategies)
	unzip(findmax.(es))
end

function oracle(payoffs::NTuple, strategies)
        players = eachindex(payoffs)

	pays = [
		bug_ncon([payoffs[i], strategies[js]...], [np, njs...])
		for (i, js, np, njs) in _nash_ids(players)
	]

	unzip(findmax.(pays))
end