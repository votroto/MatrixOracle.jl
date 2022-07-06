function _default_optimizer()
	attributes = [
		"MSK_IPAR_NUM_THREADS" => 1,
		"QUIET" => true
	]
	optimizer_with_attributes(Mosek.Optimizer, attributes...)
end

function nash_equilibrium(payoffs::NTuple{1}; optimizer=_default_optimizer())
	payoff = only(payoffs)
	axis = axes(payoff, 1)

	model = Model(optimizer)
	@variable model v
	@variable model weight[axis] >= 0
	@objective model Min v
	c = @constraint model v .>= -payoff' * weight
	@constraint model sum(weight) == 1

	optimize!(model)

	[-value(v), value(v)], [value.(weight), dual.(c)]
end
