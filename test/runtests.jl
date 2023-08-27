using Test, CryptoDashApp, Mocking, CSV, DataFrames

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

# Activate mocking for relevant test cases
Mocking.activate()

# Load mocking data
data_dir = joinpath(@__DIR__, "mocking_data")
csv_to_df(data_dir, fname) = joinpath(data_dir, fname) |> CSV.File |> DataFrame

df_price = csv_to_df(data_dir, "single_price.csv")
df_candle = csv_to_df(data_dir, "single_candle.csv")
df_vol = csv_to_df(data_dir, "single_vol.csv")
df_dev = csv_to_df(data_dir, "dev_eth.csv")
df_comm = csv_to_df(data_dir, "comm_eth.csv")
df_ex_vol = csv_to_df(data_dir, "ex_vol_eth.csv")
df_overall_vol = csv_to_df(data_dir, "overall_vol_ex.csv")

# Generate an alternative method of the target function
patch_1 = @patch CryptoDashApp.get_price_data_single(currency::String,
                                                   key::String = KEY) = return df_price,
                                                                               df_candle,
                                                                               df_vol

patch_2 = @patch CryptoDashApp.get_dev_comm_data(currency::String) = return df_dev,
                                                                            df_comm

patch_3 = @patch CryptoDashApp.get_exchange_vol_data(currency::String,
                                                     num_exchanges::Int64) = return df_ex_vol

patch_4 = @patch CryptoDashApp.get_overall_vol_data(duration::Int64,
                                                    num_exchanges::Int64) = return df_overall_vol

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