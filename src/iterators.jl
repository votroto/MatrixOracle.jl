using Base.Iterators: dropwhile

dropwhile_enumerate(pred,itr) = dropwhile(x ->pred(x[2]), enumerate(itr))

until_eps(xs, gap) = first(dropwhile_enumerate(x -> instability(x) > gap, xs))
fixed_iters(d, i) = first(drop(d, i))