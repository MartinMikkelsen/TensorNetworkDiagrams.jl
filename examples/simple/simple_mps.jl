using .TensorNetworkDiagrams

mps = MPS(4, boundary_labels = ("", ""))

save(mps, TEX("examples/simple/mps"))
save(mps, TikZ("examples/simple/mps"))

mpo = MPO(5, boundary_labels = ("", ""))

save(mpo, TEX("examples/simple/mpo"))
save(mpo, TikZ("examples/simple/mpo"))

save(mps, mpo, TEX("examples/simple/mpsmpo", standalone = true))
