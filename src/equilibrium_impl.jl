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

    x = ntuple(i -> [_simplex_var() for a in actions[i]], N)
    @variable(m, p[players])

    X = ntuple(i -> [Symbolics.variable(:X, i, a) for a in actions[i]], N)
    var_map = Dict(vcat(X...) .=> vcat(x...))

    brfs_sym = _simplify(unilateral_payoffs(payoffs, X))
    brfsX_sym = [_simplify(dot(brfs_sym[i], X[i])) for i in players]

    brfs = map(e -> _eval_sym(e, var_map), brfs_sym)
    brfsX = map(e -> _eval_sym(e, var_map), brfsX_sym)

    @constraint(m, [i = players], brfs[i] .<= p[i])
    @constraint(m, sum(brfsX) >= sum(p))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    values = ntuple(i -> value.(p[i]), N)
    strats = ntuple(i -> value.(x[i]), N)

    values, strats
end


"""
    nash_equilibrium(payoffs::NTuple{2}; optimizer=_default_optimizer())

Compute the nash equilibrium for a two-player general-sum game.
"""
function nash_equilibrium(
    payoffs::NTuple{2,AbstractMatrix};
    optimizer=_silent_optimizer()
)
    m = Model(optimizer)

    nx, ny = size(payoffs[1])
    @variable(m, xs[1:nx], lower_bound = 0, upper_bound = 1)
    @variable(m, ys[1:ny], lower_bound = 0, upper_bound = 1)
    @variable(m, w[i=1:2], lower_bound = minimum(payoffs[i]), upper_bound = maximum(payoffs[i]))

    @constraint(m, sum(xs) == 1)
    @constraint(m, sum(ys) == 1)

    @constraint(m, dot(xs, payoffs[1], ys) + dot(xs, payoffs[2], ys) >= sum(w))
    @constraint(m, (payoffs[1] * ys) .<= w[1])
    @constraint(m, (xs' * payoffs[2]) .<= w[2])

    optimize!(m)

    (value(w[1]), value(w[2])), (value.(xs), value.(ys))
end


"""
    nash_equilibrium(payoffs::NTuple{1}; optimizer=_default_optimizer())

Compute the nash equilibrium for a two-player zero-sum game.
"""
function nash_equilibrium(
    payoffs::NTuple{1,AbstractMatrix};
    optimizer=_silent_optimizer()
)
    payoff = only(payoffs)

    m = Model(optimizer)

    ny = size(payoff, 2)
    @variable(m, ys[1:ny], lower_bound = 0, upper_bound = 1)
    @variable(m, w)

    @constraint(m, sum(ys) == 1)
    @constraint(m, dx, payoff * ys .<= w)
    @objective(m, Min, w)
    optimize!(m)

    v1, v2, = value.(w), -value.(w)
    s1, s2 = abs.(dual.(dx)), value.(ys)

    (v1, v2), (s1, s2)
end