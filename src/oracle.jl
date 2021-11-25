using SparseArrays

# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

function oracle(payoff, strategies)
	ps = (payoff, -payoff')
	es = ps .* reverse(strategies)
	unzip(findmax.(es))
end
