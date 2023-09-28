using Base.Iterators: dropwhile, drop, take

dropwhile_enumerate(pred, itr) = dropwhile(x -> pred(x[2]), enumerate(itr))

limited_eps(xs, gap, n) = first(dropwhile_enumerate(x -> max_incentive(x) > gap, take(xs, n)))
until_eps(xs, gap) = first(dropwhile_enumerate(x -> max_incentive(x) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))