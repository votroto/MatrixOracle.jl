using MatrixOracle: until_eps, fixed_iters, matrix_oracle
using Random

@testset "random asymmetric two-player zero-sum" begin
    MN = (5, 7)
    payoffs = (rand(MN...),)

    oracle = matrix_oracle(payoffs)
    iters, (strats, vals, suboptim) = until_eps(oracle, 1e-3)

    @test iters <= sum(MN)
end

@testset "random asymmetric two-player general-sum" begin
    MN = (5, 7)
    payoffs = rand(MN...), rand(MN...)

    oracle = matrix_oracle(payoffs)
    iters, (strats, vals, suboptim) = until_eps(oracle, 1e-3)

    @test iters <= sum(MN)
end

@testset "3x3 guess" begin
    guess = [0 1 4; 1 0 1; 4 1 0]

    oracle = matrix_oracle((guess,))
    (s1, s2), values, = fixed_iters(oracle, 6)

    expected_values = [1, -1]
    expected_min = [0.25, 0.0, 0.25]
    expected_max = [0.75, 1.0, 0.75]
    expected_s2 = [0.0, 1.0, 0.0]

    clamped_s1 = clamp.(s1, expected_min, expected_max)
    @test isapprox(values, expected_values, atol=1e-3)
    @test isapprox(sum(s1), 1, atol=1e-3)
    @test (isapprox(s1, clamped_s1, atol=1e-3))
    @test isapprox(s2, expected_s2, atol=1e-3)
end

@testset "example from readme" begin
    A = [9 0; 0 9;;; 0 3; 3 0]
    B = [8 0; 0 8;;; 0 4; 4 0]
    C = [12 0; 0 2;;; 0 6; 6 0]
    
    iters, (strats, vals, subopt) = until_eps(matrix_oracle((A, B, C)), 1e-3)

    @test iters <= sum(size(A))
end