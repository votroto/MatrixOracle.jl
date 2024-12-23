using JuMP
using Symbolics
using Gurobi
using LinearAlgebra


"""
    nash_equilibrium(payoffs)

Computes the values and NE strategies for a multi-player general sum game.
"""
function nash_equilibrium(
    payoffs::NTuple{N,AbstractArray{T,N}}
) where {T,N}
    _simplex_var(N) = @variable(m; lower_bound=0, upper_bound=1, start=1 / N)

    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(Gurobi.Optimizer)

    x = ntuple(i -> [_simplex_var(N) for a in actions[i]], N)
    @variable(m, p[players])

    brfs = ntuple(p -> zeros(QuadExpr, actions[p]), N)
    unilateral_payoffs!(brfs, payoffs, x)
    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in actions[i])

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum_payoff >= sum(p))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    values = ntuple(i -> value.(p[i]), N)
    strats = ntuple(i -> value.(x[i]), N)

    values, strats
end

function unilateral_payoffs!(
    result::NTuple{N},
    payoffs::NTuple{N},
    strategies::NTuple{N};
    players=eachindex(payoffs)
) where {N}
    for p in players
        for i in CartesianIndices(payoffs[p])
            temp = payoffs[p][i]
            for z in players
                if z == p
                    continue
                end
                temp *= strategies[z][i.I[z]]
            end
            result[p][i.I[p]] += temp
        end
    end
    result
end

A = [9 0; 0 9;;; 0 3; 3 0]
B = [8 0; 0 8;;; 0 4; 4 0]
C = [12 0; 0 2;;; 0 6; 6 0]

nash_equilibrium((A, B, C))


A = randn(2,3,4)
B = randn(2,3,4)
C = randn(2,3,4)

nash_equilibrium((A, B, C))

