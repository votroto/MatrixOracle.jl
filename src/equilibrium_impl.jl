const GRB_ENV_REF = Ref{Gurobi.Env}()

function __init__()
    global GRB_ENV_REF
    GRB_ENV_REF[] = Gurobi.Env()
    return
end


_default_optimizer() = Gurobi.Optimizer(GRB_ENV_REF[])
_silent_optimizer() = optimizer_with_attributes(_default_optimizer, MOI.Silent() => true)


"""
    nash_equilibrium(payoffs)

Computes the values and NE strategies for a multi-player general sum game.
"""
function nash_equilibrium(
    payoffs::NTuple{N,AbstractArray{T,N}};
    optimizer=_silent_optimizer()
) where {T,N}
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


"""Computes the value and NE strategies for a zero-sum game"""
function _nash_equilibrium_zs(u::AbstractMatrix; optimizer=_silent_optimizer())
    m = Model(optimizer)

    ny = size(u, 2)
    @variable(m, ys[1:ny], lower_bound=0, upper_bound=1)
    @variable(m, w, lower_bound=minimum(u), upper_bound=maximum(u))

    @constraint(m, sum(ys) == 1)
    @constraint(m, dx, u * ys .<= w)
    @objective(m, Min, w)
    optimize!(m)

    value.(w), abs.(dual.(dx)), value.(ys)
end


"""
    nash_equilibrium(payoffs::NTuple{1}; optimizer=_default_optimizer())

Compute the nash equilibrium for a two-player zero-sum game.
"""
function nash_equilibrium(payoffs::NTuple{1})
    P = only(payoffs)

	v1, s1, s2 = _nash_equilibrium_zs(P)

    [v1, -v1], [s1, s2]
end