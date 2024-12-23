import Base: iterate, IteratorSize, IsInfinite
using Base.Iterators: dropwhile, drop
using LinearAlgebra

dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x...) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))

random_init(payoff::NTuple) = vcat.(rand.(axes(first(payoff))))
function max_incentive(_, values::NTuple{N,F}, best::NTuple{N,F}) where {N,F}
    incentive_max = typemin(F)
    for i in eachindex(values)
        incentive_i = best[i] - values[i]
        if incentive_i > incentive_max
            incentive_max = incentive_i
        end
    end
    incentive_max
end

struct MatrixOracleIterable{U,I}
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

    (strategies, values, best), extended
end