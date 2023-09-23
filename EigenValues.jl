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

  main(slv = 1, plt = 1) = begin
    I = readdlm("coo_rows.txt", Int)[:, 1]
    J = readdlm("coo_cols.txt", Int)[:, 1]
    V = readdlm("coo_vals.txt")[:, 1]

    # @show typeof(I) typeof(J) typeof(V)
    # @show I J V

    solver = (
      :Arpack,
      :KrylovKit,
      :ArnoldiMethod,
      :IterativeSolvers,
    )[slv]
    plot = (
      :UnicodePlots,
      :CairoMakie,
    )[plt]

    A = sparse(I, J, V)
    display(A)

    @show isposdef(A) ishermitian(A) issymmetric(A)

    nev = if true
      size(A, 1)  # all eigenvalues
    else
      floor(Int, √(size(A, 1)))
    end
    println("computing $nev eigenvalues using $solver")

    # TODO: wrap [FEAST](feast-solver.org) ?

    λ = @time if solver ≡ :Arpack
      eigs(A; nev) |> first  # using Arpack.jl
    elseif solver ≡ :KrylovKit
      eigsolve(A, nev; krylovdim=nev) |> first  # using KrylovKit.jl
    elseif solver ≡ :ArnoldiMethod
      dec, = partialschur(A; nev)
      dec.eigenvalues
    elseif solver ≡ :IterativeSolvers
      lobpcg(A, true, nev).λ
    else
      @error solver
    end

    if plot ≡ :UnicodePlots
      fig = scatterplot(real(λ), imag(λ))
    elseif plot ≡ :CairoMakie
      fig, ax, plot = scatter(real(λ), imag(λ))
    end
    display(fig)
    return
  end

end