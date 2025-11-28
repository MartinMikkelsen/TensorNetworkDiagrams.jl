export node

function node(shape::String = "circle", color::String = "red"; size::Float64 = 0.75)
    return "draw,shape=$shape,fill=$color,scale=$size"
end

function _draw_horizontal_bonds!(
        io::IO, length::Int, bond_labels::Vector{String},
        boundary_labels::Tuple{String, String},
        node_spacing::Float64, y::Float64
    )
    # Left boundary
    if !isempty(boundary_labels[1])
        println(io, "  \\draw[black] (-$(node_spacing),$y) -- (0,$y);")
    end

    # Internal bonds
    for i in 1:(length - 1)
        x = (i - 1) * node_spacing
        label = bond_labels[i]
        if !isempty(label)
            println(io, "  \\draw[black] ($x,$y) -- node [label={[shift={(0,-0.15)}]\$$label\$}] {} ++ ($(node_spacing),0);")
        else
            println(io, "  \\draw[black] ($x,$y) -- ++ ($(node_spacing),0);")
        end
    end

    # Right boundary
    return if !isempty(boundary_labels[2])
        x = (length - 1) * node_spacing
        println(io, "  \\draw[black] ($x,$y) -- ++ ($(node_spacing),0);")
    end
end

function _draw_vertical_legs!(
        io::IO, length::Int, physical_labels::Vector{String},
        node_spacing::Float64, y::Float64, leg_length::Float64,
        direction::Symbol, label_shift::Tuple{Float64, Float64}
    )
    for i in 0:(length - 1)
        x = i * node_spacing
        dy = direction == :up ? leg_length : -leg_length
        label = physical_labels[i + 1]
        if !isempty(label)
            println(io, "  \\draw[black] ($x,$y) -- node [label={[shift={($(label_shift[1]),$(label_shift[2]))}]\$$label\$}] {} ++ (0,$dy);")
        else
            println(io, "  \\draw[black] ($x,$y) -- ++ (0,$dy);")
        end
    end
    return
end

function _draw_nodes!(
        io::IO, length::Int, node_spacing::Float64,
        node_style::String, y::Float64; labels::Union{Vector{String}, Nothing} = nothing
    )
    for i in 0:(length - 1)
        x = i * node_spacing
        if labels === nothing
            println(io, "  \\node[$node_style] at ($x,$y){};")
        else
            node_label = labels[i + 1]
            println(io, "  \\node[$node_style,label={[shift={(0,0.30)}]\$$node_label\$}] at ($x,$y){};")
        end
    end
    return
end

function _draw_contracted_legs!(
        io::IO, overlap::Int, node_spacing::Float64,
        y_bottom::Float64, y_top::Float64
    )
    for i in 0:(overlap - 1)
        x = i * node_spacing
        println(io, "  \\draw[black] ($x,$y_bottom) -- ($x,$y_top);")
    end
    return
end
