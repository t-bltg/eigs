"""
inspired from discourse.julialang.org/t/computation-of-eigenvalues-of-a-sparse-matrix-that-is-given-by-a-file-in-coo-format/75214
"""
module EigenValues
  using NonlinearEigenproblems
  using IterativeSolvers
  using DelimitedFiles
  using LinearAlgebra
  using ArnoldiMethod
  using UnicodePlots
  using SparseArrays
  using CairoMakie
  using KrylovKit
  using Arpack

  export main

  main(slv=1, plt=1, pow=.7; rows="coo_rows.txt", cols="coo_cols.txt", vals="coo_vals.txt") = begin
    @assert 0 < pow ≤ 1
    I = readdlm(rows, Int)[:, 1]
    J = readdlm(cols, Int)[:, 1]
    V = readdlm(vals, Float64)[:, 1]

    # @show typeof(I) typeof(J) typeof(V)
    # @show I J V

    solver = (
      :Arpack,
      :KrylovKit,
      :ArnoldiMethod,
      :IterativeSolvers,
      :NonlinearEigenproblems,
    )[slv]
    plot = (
      :UnicodePlots,
      :CairoMakie,
    )[plt]

    A = sparse(I, J, V)
    display(A)

    @show isposdef(A) ishermitian(A) issymmetric(A)

    nev = floor(Int, size(A, 1)^pow)
    println("computing $nev eigenvalues using $solver")

    # TODO: wrap [FEAST](feast-solver.org) ?

    λ = @time if solver ≡ :Arpack
      eigs(A; nev) |> first  # using Arpack.jl
    elseif solver ≡ :KrylovKit
      eigsolve(A, nev; krylovdim=nev) |> first  # using KrylovKit.jl
    elseif solver ≡ :ArnoldiMethod
      dec, = partialschur(A; nev)
      dec.eigenvalues
    elseif solver ≡ :IterativeSolvers  # fails ??
      lobpcg(A, true, nev).λ
    elseif solver ≡ :NonlinearEigenproblems
      eig_solve(DefaultEigSolver(A); nev) |> first  # dispatches to :ArnoldiMethod under the hood
    else
      @error solver
    end

    fig = if plot ≡ :UnicodePlots
      scatterplot(real(λ), imag(λ); xlabel="Re", ylabel="Im")
    elseif plot ≡ :CairoMakie
      scatter(real(λ), imag(λ); axis=(; xlabel="Re", ylabel="Im")) |> first
    end
    display(fig)
    return
  end

end