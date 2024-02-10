using Mocking, CSV, DataFrames

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
                                                     key::String = AV_KEY) = return df_price,
                                                                                 df_candle,
                                                                                 df_vol

patch_2 = @patch CryptoDashApp.get_dev_comm_data(currency::String) = return df_dev,
                                                                            df_comm

patch_3 = @patch CryptoDashApp.get_exchange_vol_data(currency::String,
                                                     num_exchanges::Int64) = return df_ex_vol

patch_4 = @patch CryptoDashApp.get_overall_vol_data(duration::Int64,
                                                    num_exchanges::Int64) = return df_overall_vol