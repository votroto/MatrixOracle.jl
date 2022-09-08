using TensorOperations: ncon
using Base.Iterators: take, drop, flatten
using LinearAlgebra: dot

# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

function bug_ncon(gts, args...; kwargs...)
        ts = collect.(gts) # genericity bug in TensorOperations
	ncon(ts, args...; kwargs...)
end

function _delete_at(xs, i)
        xs[begin:end.!=i]
end

function _nash_ids(xs)
        ncon_ids(i) = [(j == i) ? -j : j for j in xs]
        ncon_js(i) = collect.(_delete_at(xs, i))
        id_not_i(i) = xs[begin:end.!=i]

        [(xs[i], id_not_i(i), ncon_ids(i), ncon_js(i)) for i in eachindex(xs)]
end