export PDF, TEX, TikZ, SVG, save

abstract type SaveFormat end

struct PDF <: SaveFormat
    filename::String
    transparent::Bool
    cleanup::Bool
    PDF(filename::String; transparent::Bool = false, cleanup::Bool = true) =
        new(_remove_extension(filename, ".pdf"), transparent, cleanup)
end

struct TEX <: SaveFormat
    filename::String
    standalone::Bool
    transparent::Bool
    TEX(filename::String; standalone::Bool = true, transparent::Bool = false) =
        new(_remove_extension(filename, ".tex"), standalone, transparent)
end

struct TikZ <: SaveFormat
    filename::String
    TikZ(filename::String) = new(_remove_extension(filename, ".tikz"))
end

struct SVG <: SaveFormat
    filename::String
    SVG(filename::String) = new(_remove_extension(filename, ".svg"))
end

function _remove_extension(filename::String, ext::String)
    return endswith(filename, ext) ? filename[1:(end - length(ext))] : filename
end

function to_tikz(mps::MPS)
    io = IOBuffer()
    println(io, "\\begin{tikzpicture}")

    _draw_horizontal_bonds!(
        io, mps.length, mps.bond_labels, mps.boundary_labels,
        mps.node_spacing, 0.0
    )

    _draw_vertical_legs!(
        io, mps.length, mps.physical_labels, mps.node_spacing,
        0.0, 0.7, :down, (0.0, -1.0)
    )

    node_labels = ["A_$i" for i in 1:mps.length]
    _draw_nodes!(io, mps.length, mps.node_spacing, mps.node_style, 0.0, labels = node_labels)

    println(io, "\\end{tikzpicture}")
    return String(take!(io))
end

function to_tikz(mpo::MPO)
    io = IOBuffer()
    println(io, "\\begin{tikzpicture}")

    _draw_horizontal_bonds!(
        io, mpo.length, mpo.bond_labels, mpo.boundary_labels,
        mpo.node_spacing, 0.0
    )

    _draw_vertical_legs!(
        io, mpo.length, mpo.upper_physical_labels, mpo.node_spacing,
        0.0, 0.7, :up, (0.0, 0.2)
    )

    _draw_vertical_legs!(
        io, mpo.length, mpo.lower_physical_labels, mpo.node_spacing,
        0.0, 0.7, :down, (0.0, -1.0)
    )

    _draw_nodes!(io, mpo.length, mpo.node_spacing, mpo.node_style, 0.0)

    println(io, "\\end{tikzpicture}")
    return String(take!(io))
end

function to_tikz(mps::MPS, mpo::MPO; vertical_spacing::Float64 = 0.7)
    io = IOBuffer()
    println(io, "\\begin{tikzpicture}")

    mps_y = vertical_spacing
    mpo_y = 0.0
    overlap = min(mps.length, mpo.length)

    _draw_horizontal_bonds!(
        io, mps.length, mps.bond_labels, mps.boundary_labels,
        mps.node_spacing, mps_y
    )

    _draw_horizontal_bonds!(
        io, mpo.length, mpo.bond_labels, mpo.boundary_labels,
        mpo.node_spacing, mpo_y
    )

    _draw_contracted_legs!(io, overlap, mps.node_spacing, mpo_y, mps_y)

    if overlap < mps.length
        uncontracted_labels = mps.physical_labels[(overlap + 1):end]
        for (idx, i) in enumerate(overlap:(mps.length - 1))
            x = i * mps.node_spacing
            label = uncontracted_labels[idx]
            if !isempty(label)
                println(io, "  \\draw[black] ($x,$mps_y) -- node [label={[shift={(0,0.2)}]\$$label\$}] {} ++ (0,$vertical_spacing);")
            else
                println(io, "  \\draw[black] ($x,$mps_y) -- ++ (0,$vertical_spacing);")
            end
        end
    end

    _draw_vertical_legs!(
        io, mpo.length, mpo.lower_physical_labels, mpo.node_spacing,
        mpo_y, vertical_spacing, :down, (0.0, -1.0)
    )

    _draw_nodes!(io, mps.length, mps.node_spacing, mps.node_style, mps_y)

    _draw_nodes!(io, mpo.length, mpo.node_spacing, mpo.node_style, mpo_y)

    println(io, "\\end{tikzpicture}")
    return String(take!(io))
end

function save(network::TensorNetwork, format::TEX)
    tikz_code = to_tikz(network)

    tex_content = if format.standalone
        bg_option = format.transparent ? ",transparent" : ""
        """
        \\documentclass[tikz,border=2mm$bg_option]{standalone}
        \\begin{document}
        $tikz_code
        \\end{document}
        """
    else
        tikz_code
    end

    filename = format.filename * ".tex"
    write(filename, tex_content)
    return println("✓ Saved to $filename")
end

function save(network::TensorNetwork, format::TikZ)
    tikz_code = to_tikz(network)
    filename = format.filename * ".tikz"
    write(filename, tikz_code)
    return println("✓ Saved TikZ code to $filename")
end

function save(network::TensorNetwork, format::PDF)
    tex_format = TEX(format.filename, standalone = true, transparent = format.transparent)
    save(network, tex_format)

    tex_file = format.filename * ".tex"
    pdf_file = format.filename * ".pdf"

    return try
        run(`sh -c "tectonic $tex_file"`)
        println("✓ Compiled to $pdf_file")

        if format.cleanup
            aux_extensions = [".aux", ".log", ".fls", ".fdb_latexmk", ".synctex.gz", ".tex"]
            for ext in aux_extensions
                file = format.filename * ext
                isfile(file) && rm(file)
            end
            println("✓ Cleaned up auxiliary files")
        end
    catch e
        @warn "Could not compile PDF. Tectonic may not be in PATH." exception = e
        println("  TEX file saved at $tex_file")
        println("  Compile manually with: tectonic $tex_file")
    end
end

function save(network::TensorNetwork, format::SVG)
    pdf_format = PDF(format.filename, transparent = true, cleanup = false)
    save(network, pdf_format)

    pdf_file = format.filename * ".pdf"
    svg_file = format.filename * ".svg"

    return try
        run(`sh -c "pdf2svg $pdf_file $svg_file"`)
        println("✓ Converted to $svg_file")
        rm(pdf_file)
    catch e
        @warn "Could not convert to SVG. pdf2svg may not be installed." exception = e
        println("  PDF file available at $pdf_file")
        println("  Convert manually with: pdf2svg $pdf_file $svg_file")
    end
end

function save(mps::MPS, mpo::MPO, format::TEX; vertical_spacing::Float64 = 0.7)
    tikz_code = to_tikz(mps, mpo, vertical_spacing = vertical_spacing)

    tex_content = if format.standalone
        bg_option = format.transparent ? ",transparent" : ""
        """
        \\documentclass[tikz,border=2mm$bg_option]{standalone}
        \\begin{document}
        $tikz_code
        \\end{document}
        """
    else
        tikz_code
    end

    filename = format.filename * ".tex"
    write(filename, tex_content)
    return println("✓ Saved to $filename")
end

function save(mps::MPS, mpo::MPO, format::TikZ; vertical_spacing::Float64 = 0.7)
    tikz_code = to_tikz(mps, mpo, vertical_spacing = vertical_spacing)
    filename = format.filename * ".tikz"
    write(filename, tikz_code)
    return println("✓ Saved TikZ code to $filename")
end

function save(mps::MPS, mpo::MPO, format::PDF; vertical_spacing::Float64 = 0.7)
    tex_file = format.filename * ".tex"
    bg_option = format.transparent ? ",transparent" : ""
    tikz_code = to_tikz(mps, mpo, vertical_spacing = vertical_spacing)

    tex_content = """
    \\documentclass[tikz,border=2mm$bg_option]{standalone}
    \\begin{document}
    $tikz_code
    \\end{document}
    """
    write(tex_file, tex_content)

    return try
        run(`sh -c "tectonic $tex_file"`)
        println("✓ Compiled to $(format.filename).pdf")

        if format.cleanup
            aux_extensions = [".aux", ".log", ".fls", ".fdb_latexmk", ".synctex.gz", ".tex"]
            for ext in aux_extensions
                file = format.filename * ext
                isfile(file) && rm(file)
            end
            println("✓ Cleaned up auxiliary files")
        end
    catch e
        @warn "Could not compile PDF" exception = e
        println("  TEX file saved at $tex_file")
    end
end

function save(mps::MPS, mpo::MPO, format::SVG; vertical_spacing::Float64 = 0.7)
    pdf_format = PDF(format.filename, transparent = true, cleanup = false)
    save(mps, mpo, pdf_format, vertical_spacing = vertical_spacing)

    pdf_file = format.filename * ".pdf"
    svg_file = format.filename * ".svg"

    return try
        run(`sh -c "pdf2svg $pdf_file $svg_file"`)
        println("✓ Converted to $svg_file")
        rm(pdf_file)
    catch e
        @warn "Could not convert to SVG" exception = e
        println("  PDF file available at $pdf_file")
    end
end
