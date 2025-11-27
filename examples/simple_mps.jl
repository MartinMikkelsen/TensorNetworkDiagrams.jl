using .TensorNetworkDiagrams


mps = MPS(length=4)
tikz = to_tikz(mps)

save_tex(tikz, "mps.tex")

mpo = MPO(4)
tikz_mpo = to_tikz(mpo)
save_tex(tikz_mpo, "mpo.tex")
