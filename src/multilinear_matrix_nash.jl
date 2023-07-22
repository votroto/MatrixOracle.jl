using JuMP
using Gurobi
using LinearAlgebra
using Symbolics

include("jump_extensions.jl")

const _ENV = Gurobi.Env()
_OPT() = Gurobi.Optimizer(_ENV)
_DEFAULT_OPTIMIZER = optimizer_with_attributes(_OPT, MOI.Silent() => true, "Nonconvex" => 2)

function nash_equilibrium(
    payoffs::NTuple{N, AbstractArray{T, N}};
    optimizer=_DEFAULT_OPTIMIZER
) where {T, N}
    _simplify(expr) = Symbolics.simplify(expr; expand=true)

    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(optimizer)

    _simplex_var(i, a) = @variable(m, base_name = "x[$i,$a]"; lower_bound=0, upper_bound=1, start=0)
    x = [[_simplex_var(i, a) for a in actions[i]] for i in players]
    @variable(m, p[players])

    X = [[Symbolics.variable(:X, i, a) for a in actions[i]] for i in players]
    vdict = Dict(vcat(X...) .=> vcat(x...))

    brfs_sym = _simplify(unilateral_payoffs(payoffs, X, players))
    brfsX_sym = [_simplify(dot(brfs_sym[i], X[i])) for i in players]

    brfs = map(e -> Symbolics.value.(Symbolics.substitute(e, vdict)), brfs_sym)
    brfsX = map(e -> Symbolics.value.(Symbolics.substitute(e, vdict)), brfsX_sym)

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p))

    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    value.(p), [value.(xi) for xi in x]
end
