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

Finds a nash equilibrium of a strategic game. Returns the payoffs and the
corresponding strategies.
"""
function nash_equilibrium(
    payoffs::NTuple{N,AbstractArray{T,N}};
    optimizer=_silent_optimizer()
) where {T,N}
    _simplex_var(N) = @variable(m; lower_bound=0, upper_bound=1, start=1 / N)

    players = eachindex(payoffs)
    actions = axes(first(payoffs))

    m = Model(optimizer)

    pay_ub = ntuple(i -> maximum(payoffs[i]), N)
    pay_lb = ntuple(i -> minimum(payoffs[i]), N)
    x = ntuple(i -> [_simplex_var(N) for a in actions[i]], N)
    @variable(m, w[i=players], lower_bound = pay_lb[i], upper_bound = pay_ub[i])

    brfs = ntuple(i -> zeros(NonlinearExpr, actions[i]), N)
    unilateral_payoffs!(brfs, payoffs, x)

    sum_payoff = sum(brfs[i][a] * x[i][a] for i in players for a in actions[i])
    @constraint(m, [i = players], brfs[i] .<= w[i])
    @constraint(m, sum_payoff >= sum(w))
    @constraint(m, [i = players], sum(x[i]) == 1)

    optimize!(m)

    values = ntuple(i -> value.(w[i]), N)
    strats = ntuple(i -> value.(x[i]), N)

    values, strats
end

function nash_equilibrium(
    payoffs::NTuple{2,AbstractMatrix};
    optimizer=_silent_optimizer()
)
    m = Model(optimizer)

    pay_ub = ntuple(i -> maximum(payoffs[i]), 2)
    pay_lb = ntuple(i -> minimum(payoffs[i]), 2)
    nx, ny = size(payoffs[1])
    @variable(m, xs[1:nx], lower_bound = 0, upper_bound = 1)
    @variable(m, ys[1:ny], lower_bound = 0, upper_bound = 1)
    @variable(m, w[i=1:2], lower_bound = pay_lb[i], upper_bound = pay_ub[i])

    @constraint(m, sum(xs) == 1)
    @constraint(m, sum(ys) == 1)

    @constraint(m, dot(xs, payoffs[1], ys) + dot(xs, payoffs[2], ys) >= sum(w))
    @constraint(m, (payoffs[1] * ys) .<= w[1])
    @constraint(m, (xs' * payoffs[2]) .<= w[2])

    optimize!(m)

    (value(w[1]), value(w[2])), (value.(xs), value.(ys))
end

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