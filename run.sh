#!/usr/bin/env bash
{
  julia --project=. -i -e '
using Pkg; Pkg.resolve()
using Revise

Revise.includet("EigenValues.jl")
using .EigenValues

main()
'
  exit
}