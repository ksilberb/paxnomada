countNucs(s::String) = [
    count(==('A'), s), count(==('C'), s), count(==('G'), s), count(==('T'), s)
]

function main()
    if length(ARGS) < 2
        println("Usage: julia $(Base.PROGRAM_FILE) <fileIN> <fileOUT>")
        exit(1)
    end
    s = read(ARGS[1], String)
    data = countNucs(s)
    open(ARGS[2], "w") do file
        println(file, join(data, " "))
    end
    exit(0)
end

main()
