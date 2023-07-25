using JuMP
using LinearAlgebra
using Symbolics
using SCIP

_DEFAULT_OPTIMIZER = optimizer_with_attributes(SCIP.Optimizer, MOI.Silent() => true)

function nash_equilibrium(
    payoffs::NTuple{N, AbstractArray{T, N}};
    optimizer=_DEFAULT_OPTIMIZER
) where {T, N}
    _simplify(expr) = Symbolics.simplify(expr; expand=true)
    _eval_sym(expr, dict) = Symbolics.value.(Symbolics.substitute(expr, dict))
    _simplex_var() = @variable(m; lower_bound=0, upper_bound=1, start=0)

    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(optimizer)

    x = [[_simplex_var() for a in actions[i]] for i in players]
    @variable(m, p[players])

    X = [[Symbolics.variable(:X, i, a) for a in actions[i]] for i in players]
    var_map = Dict(vcat(X...) .=> vcat(x...))

    brfs_sym = _simplify(unilateral_payoffs(payoffs, X))
    brfsX_sym = [_simplify(dot(brfs_sym[i], X[i])) for i in players]

    brfs = map(e -> _eval_sym(e, var_map), brfs_sym)
    brfsX = map(e -> _eval_sym(e, var_map), brfsX_sym)

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    value.(p), [value.(xi) for xi in x]
end
