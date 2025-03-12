transcribe(s::AbstractString) = replace(s, 'T'=>'U')

function main()
    if length(ARGS) < 2
        println("Usage: julia $(Base.PROGRAM_FILE) <fineIN> <fileOUT>")
        exit(1)
    end

    s = read(ARGS[1], String)

    open(ARGS[2], "w") do file
        println(file, transcribe(s))
    end
    exit(0)
end

main()
