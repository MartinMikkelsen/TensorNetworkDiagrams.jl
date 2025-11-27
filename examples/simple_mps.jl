using .TensorNetworkDiagrams

mps = MPS(length = 4, boundary_labels = ("", ""))
tikz = to_tikz(mps)

save_tex(tikz, "examples/mps.tex")

mpo = MPO(5, boundary_labels = ("", ""))
tikz_mpo = to_tikz(mpo)
save_tex(tikz_mpo, "examples/mpo.tex")

tikz_TN = to_tikz(mps, mpo)
save_tex(tikz_TN, "examples/tensornetwork.tex", transparent=false)
