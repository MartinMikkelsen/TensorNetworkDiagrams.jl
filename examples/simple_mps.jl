using .TensorNetworkDiagrams

mps = MPS(4, boundary_labels = ("", ""))
tikz = to_tikz(mps)

save(mps, TEX("mps"))
save(mps, TikZ("mps"))
save(mps, PDF("mps"))
save(mps, SVG("mps"))

mpo = MPO(5, boundary_labels = ("", ""))

save(mps, TEX("mpo"))
save(mps, TikZ("mpo"))
save(mps, PDF("mpo"))
save(mps, SVG("mpo"))

save(mps, mpo, PDF("contract"))
save(mps, mpo, TEX("contract", standalone = false))
save(mps, mpo, SVG("contract"), vertical_spacing = 1.0)