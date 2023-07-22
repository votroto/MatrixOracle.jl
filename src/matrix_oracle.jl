import Base: iterate, IteratorSize, IsInfinite
using LinearAlgebra

random_init(payoff::NTuple) = vcat.(rand.(axes(first(payoff))))
max_incentive((_, values, best)) = norm(best - values, Inf)

struct MatrixOracleIterable{U, I}
	payoff::U
	init::I
end

IteratorSize(::Type{MatrixOracleIterable}) = IsInfinite()

function matrix_oracle(payoff; init=random_init(payoff))
	MatrixOracleIterable(payoff, init)
end

function iterate(mo::MatrixOracleIterable, pures=mo.init)
	values, strategies = equilibrium(mo.payoff, pures)
	best, responses = oracle(mo.payoff, strategies)
	extended = unique.(vcat.(pures, responses), dims=1)

	worsts =  worst(mo.payoff, strategies)
	for (i, e) in enumerate(extended)
		if length(e) > rank(mo.payoff[(i-1)%length(mo.payoff)+1]) + 1
			extended[i] = extended[i][begin:end .!= worsts[i]]
		end
	end

	(strategies, values, best), extended
end