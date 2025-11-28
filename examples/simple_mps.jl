using .TensorNetworkDiagrams

mps = MPS(4, boundary_labels = ("", ""))

save(mps, TEX("examples/mps"))
save(mps, TikZ("examples/mps"))

mpo = MPO(5, boundary_labels = ("", ""))

save(mps, TEX("examples/mpo"))
save(mps, TikZ("examples/mpo"))

save(mps, mpo, TEX("examples/mpsmpo", standalone = true))