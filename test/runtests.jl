using Test, JSON, CryptoDashApp

# Get both API keys locally and during CI
local_dir = joinpath("/home", "vikas", "Documents")
AV_file = joinpath(local_dir, "AV_demo_key.json")
CG_file = joinpath(local_dir, "CG_demo_key.json")

if isfile(AV_file)
    key_dict = JSON.parsefile(AV_file)
    const AV_KEY = key_dict["key"]
elseif haskey(ENV, "KEY_AV")
    const AV_KEY = ENV["KEY_AV"]
else
    error("API key for AlphaVantage has not been provided!")
end

if isfile(CG_file)
    key_dict = JSON.parsefile(CG_file)
    const CG_KEY = key_dict["key"]
elseif haskey(ENV, "KEY_CG")
    const CG_KEY = ENV["KEY_CG"]
else
    error("API key for CoinGecko has not been provided!")
end

errors = false
all_tests = false

# Run all tests when no arguments or "all" is specified
if isempty(ARGS) || "all" in ARGS
    all_tests = true
end

# Enable mocking
include("mocking_setup.jl")

# Execute test in a try-catch block for each file
function execute_test(file::String, ARGS; all_tests::Bool, errors::Bool)

    if all_tests || file in ARGS
        try
            include(file)
            println("\t\033[1m\033[32mPASSED\033[0m: $(file)")
        catch e
            println("\t\033[1m\033[31mFAILED\033[0m: $(file)")
            global errors = true
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