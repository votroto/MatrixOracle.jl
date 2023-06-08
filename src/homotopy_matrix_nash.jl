using HomotopyContinuation
using Base.Iterators: flatten

function _hc_value(variable, system, path)
        i = findfirst(isequal(variable), system.variables)
        path.solution[i]
end

function extract_solution(s, player_vars, system, path)
        _value(var) = real(_hc_value(var, system, path))

        payoffs = _value.(s)
        strats = [_value.(p) for p in player_vars]

        (payoffs, strats)
end

function _is_strategy(strats; tol=1e-3)
        sums_to_one(s) = isapprox(sum(s), 1; atol=tol)
        between_0_1(s) = all((i >= 0 - tol) for i in s)

        all(between_0_1(s) && sums_to_one(s) for s in strats)
end

function _is_solution(s, xs, system, path)
        (_, x) = extract_solution(s, xs, system, path)
        is_real(path) && _is_strategy(x)
end

function solve_homotopy(payoffs; start_system=:polyhedral)
        players = eachindex(payoffs)
        actions = axes(first(payoffs))

        xs = [first(@var x[d, a]) for (d, a) in enumerate(actions)]
        @var s[players]

        pays = unilateral_payoffs(payoffs, xs, players)

        constr_simplex = [sum(xs[p]) - 1 for p in players]
        constr_best_resp = [xs[i] .* (s[i] .- p) for (i, p) in enumerate(pays)]

        variables = collect(flatten([xs; s]))
        system = System([constr_simplex; constr_best_resp...], variables)

        result = HomotopyContinuation.solve(system; 
                show_progress=false,
                compile=false,
                tracker_options=TrackerOptions(parameters=:fast),
                stop_early_cb=p->_is_solution(s, xs, system, p),
                start_system)

        [extract_solution(s, xs, system, p) for p in result.path_results]
end

function multiple_start_homotopy(payoffs)
        sols = solve_homotopy(payoffs; start_system=:polyhedral)
        if !isempty(sols)
                return sols
        end
        solve_homotopy(payoffs; start_system=:total_degree)
end


"""
    nash_equilibrium(payoffs::NTuple)

Compute the Nash equilibrium of a general matrix game using homotopy methods.
"""
function nash_equilibrium(payoffs::NTuple)
        payoffs |> multiple_start_homotopy |> first
end