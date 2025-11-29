using .TensorNetworkDiagrams

mps = MPS(6)

@show nodes = node("rectangle","yellow")

mpo = MPO(6, node_style=nodes)

save(mps,TEX("examples/custom_mps/mps"))
save(mpo,TEX("examples/custom_mps/mpo"))

save(mps, mpo, TEX("examples/custom_mps/mpsmpo", standalone = true))
