using DelimitedFiles

function nash_equilibrium(payoffs::NTuple)
	fil = IOBuffer(mk_nfg(payoffs))

	pip = pipeline(`timeout 30 python src/gambit.py`, stdin=fil)
	out = readchomp(pip)
	lines = split(out, '\n')

	pay_line = IOBuffer(lines[1])
	strat_lines = IOBuffer.(lines[2:end])

	pay = vec(readdlm(pay_line))
	strats = map(x->vec(x), readdlm.(strat_lines))

	pay, strats
end

function mk_nfg(payoffs::NTuple)
	n_strategies = size(first(payoffs))
	strategies = axes(first(payoffs))
	pnames = join(map(p -> "\"p$p\"", eachindex(strategies)), ' ')
	nstrat = join(map(string, n_strategies), ' ')

	res = IOBuffer()

	println(res, "NFG 1 R \"game\"")
	println(res, "{$pnames} {$nstrat}")
	println(res, "")

	println(res, join(map(z -> join(z, ' '), zip(payoffs...)), ' '))

	String(take!(res))
end
