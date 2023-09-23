#!/usr/bin/env bash
{
  julia --project=. -i -e '
using Pkg; Pkg.resolve()
using Revise
Revise.includet("EigenValues.jl")
main(args...; kw...) = EigenValues.main(args...; kw...)
main()
'
  exit
}