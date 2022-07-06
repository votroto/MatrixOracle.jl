
# Thanks, ivirshup! Julia, please implement.
unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

function bug_ncon(gts, args...; kwargs...)
        ts = collect.(gts) # genericity bug in TensorOperations
	ncon(ts, args...; kwargs...)
end