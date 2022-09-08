include("../src/MatrixOracle.jl")
#using MatrixOracle
using Random
using Statistics
using Base.Threads

function tdo(ps)
        try
                t = @timed until_eps(matrix_oracle(ps), 1e-8)
                t.time
        catch y
                NaN32
        end
end

function tgb(ps)
        try
                t = @timed nash_equilibrium(ps)
                t.time
        catch y
                NaN32
        end
end

function time_do_vs_gb(strats, players)
        r = Tuple(eachslice(randn(players, fill(strats, players)...), dims=1))

        d = tdo(r)
        g = tgb(r)

        d, g
end

function btdo(io, p, sl, sh, iters)
        Threads.@threads for s in sl:sh
                for j in 1:iters
                        d, g = time_do_vs_gb(s, p)
                        println("$p $s $j $d $g")
                        println(io, "$p $s $j $d $g")
                end
        end
end
