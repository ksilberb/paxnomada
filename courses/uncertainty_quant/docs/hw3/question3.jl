using GLMakie
using Distributions
using KernelDensity
using SpecialFunctions
using QuadGK

p(x) = ((2*(2^(1.0/4.0)))/(gamma((1.0/4.0))))*exp(-2.0*x^4)

function question3c()
    x = LinRange(-2, 2, 1000)
    fig = Figure()
    ax = Axis(fig[1, 1], title = L"$p^*(x) = \frac{2(2)^\frac{1}{4}}{\Gamma\left(\frac{1}{4}\right)}e^{-2x^4}$",
              xlabel = L"$x$",
              ylabel = L"$p^*(x)$")
    lines!(ax, x, p.(x))
    save("question3c.png", fig)
end

function question3partE()
    Δt = 1e-4
    ts = 0.0:Δt:5.0
    N = 5
    W = Normal(0, sqrt(Δt))
    procs = Matrix{Float64}(undef, length(ts), N)
    for i in 1:N
        procs[1, i] = rand() + 1.0
    end

    for i in 1:N
        for j in 2:length(ts)
            procs[j, i] = procs[j-1, i] - (procs[j-1, i]^3)*Δt + 0.5*rand(W)
        end
    end

    fig = Figure()
    ax = Axis(fig[1, 1],
        title = L"$X_{k+1} = X_k - X_k^3 \Delta t + \frac{1}{2} \Delta W_k$",
        xlabel = "x")
    for i in 1:N
        lines!(ax, ts, procs[:, i])
    end
    save("question3e.png", fig)
end

function question3partF()
    Δt = 1e-4
    ts = 0.0:Δt:5.0
    N = 200
    W = Normal(0, sqrt(Δt))
    procs = Matrix{Float64}(undef, length(ts), N)
    println("initializing matrix with uniform random numbers in [1, 2]")
    for i in 1:N
        procs[1, i] = rand() + 1.0
    end
    println("simulating random process")
    for i in 1:N
        println("$N complete")
        for j in 2:length(ts)
            procs[j, i] = procs[j-1, i] - (procs[j-1, i]^3)*Δt + 0.5*rand(W)
        end
    end

    fig = Figure();display(fig)
    ax1 = Axis(fig[1, 1],
    title = "$N SDE paths")
    ax2 = Axis(fig[1, 2],
        title = "KDE Density")
    x = LinRange(-5, 5, 1000)
    xlims!(ax2, -5, 5)
    for i in 1:N
        lines!(ax1, ts, procs[:, i], linewidth = 1)
    end
    d = kde(procs[1, :])
    vlinet = Observable(ts[1])
    kde_data = Observable((d.x, d.density))
    kde_line = lines!(ax2, [0.0], [0.0], color = :blue, label = "KDE")

    kde_plot = lift(kde_data) do (x, density)
        kde_line[1] = x
        kde_line[2] = density
    end

    vlines!(ax1, vlinet, color = :red, label = "time")
    lines!(ax2, x, p.(x), color = :red, linestyle = :dash, label = L"$p^*(x)$")
    Legend(fig[2, 1], ax1, orientation = :horizontal)
    Legend(fig[2, 2], ax2, orientation = :horizontal)
    println("starting video rendering...")
    record(fig, "question3partF.mp4", 2:100:length(ts); framerate = 30) do k
        println("frame $k")
        vlinet[] = ts[k]
        d = kde(procs[k, :])
        kde_data[] = (d.x, d.density)
    end
    println("video rendered")
end

function question3partF_optimized()
    # Simulation parameters
    Δt = 1e-4
    ts = 0.0:Δt:5.0
    N = 1000
    W = Normal(0, sqrt(Δt))

    # Initialize matrix with uniform random numbers in [1, 2]
    println("Initializing matrix with uniform random numbers in [1, 2]")
    procs = Matrix{Float64}(undef, length(ts), N)
    for i in 1:N
        procs[1, i] = rand() + 1.0
    end

    # Simulate random process
    println("Simulating random process...")
    for i in 1:N
        if i % 100 == 0
            println("$i/$N paths complete")
        end
        for j in 2:length(ts)
            procs[j, i] = procs[j-1, i] - (procs[j-1, i]^3)*Δt + 0.5*rand(W)
        end
    end

    # Pre-compute all KDE data for animation frames
    println("Pre-computing KDE data for animation frames...")
    frame_indices = 2:100:length(ts)  # Every 100th frame
    kde_results = Vector{Tuple{Vector{Float64}, Vector{Float64}}}()

    for (frame_num, k) in enumerate(frame_indices)
        if frame_num % 50 == 0
            println("Pre-computing KDE $frame_num/$(length(frame_indices))")
        end
        d = kde(procs[k, :])
        push!(kde_results, (d.x, d.density))
    end

    # Create figure and setup
    fig = Figure()
    ax1 = Axis(fig[1, 1], title = "$N SDE paths")
    ax2 = Axis(fig[1, 2], title = "KDE Density")

    # Plot all paths (static)
    println("Plotting sample paths...")
    for i in 1:min(N, 50)  # Only plot first 50 paths to avoid clutter
        lines!(ax1, ts, procs[:, i], linewidth = 1, alpha = 0.3)
    end

    # Setup animated elements
    x_analytic = LinRange(-5, 5, 1000)
    xlims!(ax2, -5, 5)

    # Observables for animation
    vlinet = Observable(ts[frame_indices[1]])
    kde_x = Observable(kde_results[1][1])
    kde_y = Observable(kde_results[1][2])

    # Create plot elements
    vlines!(ax1, vlinet, color = :red, linewidth = 2, label = "current time")
    kde_line = lines!(ax2, kde_x, kde_y, color = :blue, linewidth = 2, label = "KDE")
    lines!(ax2, x_analytic, p.(x_analytic), color = :red, linestyle = :dash,
           linewidth = 2, label = L"$p^*(x)$ (analytical)")

    # Add legends
    Legend(fig[2, 1], ax1, orientation = :horizontal)
    Legend(fig[2, 2], ax2, orientation = :horizontal)

    # Render video with pre-computed data
    println("Rendering video with pre-computed data...")
    record(fig, "question3partF_optimized.mp4", enumerate(frame_indices); framerate = 30) do (i, k)
        if i % 50 == 0
            println("Rendering frame $i/$(length(frame_indices))")
        end
        # Update observables with pre-computed data (very fast)
        vlinet[] = ts[k]
        kde_x[] = kde_results[i][1]
        kde_y[] = kde_results[i][2]
    end

    println("Video saved as 'question3partF_optimized.mp4'")
    return fig
end
