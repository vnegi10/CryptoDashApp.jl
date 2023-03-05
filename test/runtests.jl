using Test, CryptoDashApp

# Free API key
global KEY = "AKTJ25ALEBBLH1QJ"

location = joinpath(@__DIR__, "data")

# Check if "data" folder exists, if not, create a new one
if isdir(location)
    @info "data folder exists, cleanup action will be performed!"
else
    mkpath(location)
    @info "New data folder has been created"
end

# Perform cleanup of old data
CryptoDashApp.remove_old_files()

errors = false
all_tests = false

# Run all tests when no arguments or "all" is specified
if isempty(ARGS) || "all" in ARGS
    all_tests = true
end

# Execute test in a try-catch block for each file
function execute_test(file::String, ARGS; all_tests::Bool, errors::Bool)

    if all_tests || file in ARGS
        try
            include(file)
            println("\t\033[1m\033[32mPASSED\033[0m: $(file)")
        catch e
            println("\t\033[1m\033[31mFAILED\033[0m: $(file)")
            errors = true
            showerror(stdout, e, backtrace())
            println()
        end
    end
    
end


################# All test groups #################

test_files = ["test_API_CG.jl",
              "test_marketdata_AV.jl",
              "test_movingaverages.jl",
              "test_plots_AV.jl",
              "test_plots_CG.jl",
              "test_exceptions.jl"]

###################################################

################# Execute tests ###################

@time for file in test_files
    execute_test(file, ARGS, all_tests = all_tests, errors = errors)
end

if errors
    throw("Some tests have failed! Check the results summary above.")
end

###################################################