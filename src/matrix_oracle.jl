import Base: iterate, IteratorSize, IsInfinite
using Base.Iterators: dropwhile, drop
using LinearAlgebra


dropwhile_counting(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))


"""
Run the iterator `xs` until the first iteration where the exploitability is
below or equal to `gap`.
"""
until_eps(xs, gap) = first(dropwhile_counting(x -> max_incentive(x...) > gap, xs))


"""
Run the iterator `xs` for a fixed number of iterations `i`.
"""
fixed_iters(xs, i) = first(drop(xs, i))


random_init(payoffs::NTuple{N}) where {N} = ntuple(i -> [rand(axes(payoffs[i], i))], N)
random_init(payoffs::NTuple{1}) = random_init((only(payoffs), only(payoffs)))


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