using TensorOperations: ncon

# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x -> getfield.(a, x), fieldnames(eltype(a)))

function _bug_ncon(gts, args...; kwargs...)
    ts = collect.(gts) # genericity bug in TensorOperations
    ncon(ts, args...; kwargs...)
end

function _ncon_ids(xs)
    delete_at(xs, i) = xs[begin:end.!=i]
    ncon_ids(i) = [(j == i) ? -j : j for j in xs]
    ncon_js(i) = collect.(delete_at(xs, i))
    id_not_i(i) = xs[begin:end.!=i]
    
    [(xs[i], id_not_i(i), ncon_ids(i), ncon_js(i)) for i in eachindex(xs)]
end

"""
unilateral_payoffs(payoffs::NTuple, strategies, players)

Computes the payoffs that each player could get by unilateral deviation.
"""
function unilateral_payoffs(
    payoffs::NTuple,
    strategies;
    players=eachindex(payoffs)
    )
    function contract((i, js, np, njs))
        _bug_ncon([payoffs[i], strategies[js]...], [np, njs...])
    end
    map(contract, _ncon_ids(players))
end