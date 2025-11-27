module TensorNetworkDiagrams

export MPS, MPO, to_tikz, save_tex, node

struct MPS
    length::Int
    bond_labels::Vector{String}
    physical_labels::Vector{String}
    boundary_labels::Tuple{String, String}
    node_spacing::Float64
    node_style::String
end

struct MPO
    length::Int
    bond_labels::Vector{String}
    upper_physical_labels::Vector{String}
    lower_physical_labels::Vector{String}
    boundary_labels::Tuple{String, String}
    node_spacing::Float64
    node_style::String
end

function node(shape::String = "circle", color::String = "red"; size::Float64 = 0.75)
    return "draw,shape=$shape,fill=$color,scale=$size"
end

function MPS(
        length::Int;
        bond_label::Union{String, Nothing} = nothing,
        physical_label::Union{String, Nothing} = nothing,
        boundary_labels::Tuple{String, String} = ("1", "1"),
        node_spacing::Float64 = 1.0,
        node_style::String = node()
    )
    bond_labels = if bond_label === nothing
        ["\\alpha_$i" for i in 1:(length - 1)]
    else
        ["$(bond_label)_$i" for i in 1:(length - 1)]
    end

    physical_labels = if physical_label === nothing
        ["\\kappa_$i" for i in 1:length]
    else
        ["$(physical_label)_$i" for i in 1:length]
    end

    return MPS(length, bond_labels, physical_labels, boundary_labels, node_spacing, node_style)
end

function MPS(;
        length::Int,
        bond_labels = ["\\alpha_$i" for i in 1:(length - 1)],
        physical_labels = ["\\kappa_$i" for i in 1:length],
        boundary_labels = ("1", "1"),
        node_spacing = 1.0,
        node_style = "draw,shape=circle,fill=red,scale=0.75"
    )
    return MPS(length, bond_labels, physical_labels, boundary_labels, node_spacing, node_style)
end

function MPO(
    length::Int;
    bond_label::Union{String, Nothing} = nothing,
    upper_physical_label::Union{String, Nothing} = nothing,
    lower_physical_label::Union{String, Nothing} = nothing,
    boundary_labels::Tuple{String, String} = ("1", "1"),
    node_spacing::Float64 = 1.0,
    node_style::String = node("circle", "orange")
)
    # Generate default labels if not provided
    bond_labels = if bond_label === nothing
        ["\\alpha_$i" for i in 1:(length - 1)]
    else
        ["$(bond_label)_$i" for i in 1:(length - 1)]
    end
    
    upper_physical_labels = if upper_physical_label === nothing
        ["\\beta_$i" for i in 1:length]
    else
        ["$(upper_physical_label)_$i" for i in 1:length]
    end
    
    lower_physical_labels = if lower_physical_label === nothing
        ["\\kappa_$i" for i in 1:length]
    else
        ["$(lower_physical_label)_$i" for i in 1:length]
    end
    
    return MPO(length, bond_labels, upper_physical_labels, lower_physical_labels, 
               boundary_labels, node_spacing, node_style)
end

function to_tikz(mps::MPS)
    io = IOBuffer()
    println(io, "\\begin{tikzpicture}")

    # Draw left boundary bond
    println(io, "  \\draw[black] (-$(mps.node_spacing),0) -- node [label={[shift={(0,-0.15)}]\$$(mps.boundary_labels[1])\$}] {} (0,0);")

    # Draw internal bonds
    for i in 1:(mps.length - 1)
        x = (i - 1) * mps.node_spacing
        println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0,-0.15)}]\$$(mps.bond_labels[i])\$}] {} ++ ($(mps.node_spacing),0);")
    end

    # Draw right boundary bond
    x = (mps.length - 1) * mps.node_spacing
    println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0,-0.15)}]\$$(mps.boundary_labels[2])\$}] {} ++ ($(mps.node_spacing),0);")

    # Draw physical legs
    for i in 0:(mps.length - 1)
        x = i * mps.node_spacing
        println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0,-1)}]\$$(mps.physical_labels[i + 1])\$}] {} ++ (0,-0.7);")
    end

    # Draw nodes
    for i in 0:(mps.length - 1)
        x = i * mps.node_spacing
        node_label = "A_$(i + 1)"
        println(io, "  \\node[$(mps.node_style),label={[shift={(0,0.30)}]\$$node_label\$}] at ($x,0){};")
    end

    println(io, "\\end{tikzpicture}")
    return String(take!(io))
end

function to_tikz(mpo::MPO)
    io = IOBuffer()
    println(io, "\\begin{tikzpicture}")
    
    # Draw left boundary bond
    println(io, "  \\draw[black] (-$(mpo.node_spacing),0) -- node [label={[shift={(0,-0.15)}]\$$(mpo.boundary_labels[1])\$}] {} (0,0);")
    
    # Draw internal bonds
    for i in 1:mpo.length-1
        x = (i-1) * mpo.node_spacing
        println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0,-0.15)}]\$$(mpo.bond_labels[i])\$}] {} ++ ($(mpo.node_spacing),0);")
    end
    
    # Draw right boundary bond
    x = (mpo.length - 1) * mpo.node_spacing
    println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0,-0.15)}]\$$(mpo.boundary_labels[2])\$}] {} ++ ($(mpo.node_spacing),0);")
    
    # Draw upper physical legs
    for i in 0:mpo.length-1
        x = i * mpo.node_spacing
        println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0.0,0.2)}]\$$(mpo.upper_physical_labels[i+1])\$}] {} ++ (0,0.7);")
    end
    
    # Draw lower physical legs
    for i in 0:mpo.length-1
        x = i * mpo.node_spacing
        println(io, "  \\draw[black] ($x,0) -- node [label={[shift={(0.0,-1.0)}]\$$(mpo.lower_physical_labels[i+1])\$}] {} ++ (0,-0.7);")
    end
    
    # Draw nodes
    for i in 0:mpo.length-1
        x = i * mpo.node_spacing
        println(io, "  \\node[$(mpo.node_style)] at ($x,0){};")
    end
    
    println(io, "\\end{tikzpicture}")
    String(take!(io))
end

function save_tex(tikz_code::String, filename::String; standalone = true, cleanup = true)
    tex_content = if standalone
        """
        \\documentclass[tikz,border=2mm]{standalone}
        \\begin{document}
        $tikz_code
        \\end{document}
        """
    else
        tikz_code
    end

    write(filename, tex_content)
    println("✓ Saved to $filename")
    println("  Compile with: tectonic $filename")

    return if cleanup
        base = replace(filename, ".tex" => "")
        aux_extensions = [".aux", ".log", ".fls", ".fdb_latexmk", ".synctex.gz"]
        println("  Then clean up with: rm $base.{aux,log,fls,fdb_latexmk,synctex.gz}")
    end
end


end 
