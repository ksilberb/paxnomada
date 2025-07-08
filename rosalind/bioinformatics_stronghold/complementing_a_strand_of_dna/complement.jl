function reverse_complement(s::AbstractString)
    rev_map = Dict{Char, Char}(
        'A' => 'T', 'T' => 'A',
        'G' => 'C', 'C' => 'G'
    )
    io = IOBuffer()
    for char in reverse(s)
        write(io, rev_map[char])
    end
    return String(take!(io))
end

function main()
    first_line = readline(ARGS[1])
    output = reverse_complement(first_line)
    write("output.txt", output)
    println(output)
end

main()
