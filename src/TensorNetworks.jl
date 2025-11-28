export MPS, MPO

abstract type TensorNetwork end

struct MPS <: TensorNetwork
    length::Int
    bond_labels::Vector{String}
    physical_labels::Vector{String}
    boundary_labels::Tuple{String, String}
    node_spacing::Float64
    node_style::String
end

struct MPO <: TensorNetwork
    length::Int
    bond_labels::Vector{String}
    upper_physical_labels::Vector{String}
    lower_physical_labels::Vector{String}
    boundary_labels::Tuple{String, String}
    node_spacing::Float64
    node_style::String
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

function MPO(
        length::Int;
        bond_label::Union{String, Nothing} = nothing,
        upper_physical_label::Union{String, Nothing} = nothing,
        lower_physical_label::Union{String, Nothing} = nothing,
        boundary_labels::Tuple{String, String} = ("1", "1"),
        node_spacing::Float64 = 1.0,
        node_style::String = node("circle", "orange")
    )
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

    return MPO(
        length, bond_labels, upper_physical_labels, lower_physical_labels,
        boundary_labels, node_spacing, node_style
    )
end
