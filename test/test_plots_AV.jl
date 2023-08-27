################# Test cases for plots using AlphaVantage data #################

Mocking.activate()

# Load mocking data
data_dir = joinpath(@__DIR__, "mocking_data")
csv_to_df(data_dir, fname) = joinpath(data_dir, fname) |> CSV.File |> DataFrame

df_price = csv_to_df(data_dir, "single_price.csv")
df_candle = csv_to_df(data_dir, "single_candle.csv")
df_vol = csv_to_df(data_dir, "single_vol.csv")

# Generate an alternative method of the target function
patch = @patch CryptoDashApp.get_price_data_single(currency::String,
                                                   key::String = KEY) = return df_price,
                                                                               df_candle,
                                                                               df_vol

@testset "plot_price_ma_trade_data" begin

    apply(patch) do

        all_traces = CryptoDashApp.plot_price_ma_trade_data(10, 90, 30, KEY)
        @test ~isempty(all_traces)

        for trace in all_traces
            @test trace.fields[:y] |> length == 90
        end

    end

end

@testset "plot_price_bollinger_bands" begin

    apply(patch) do

        all_traces = CryptoDashApp.plot_price_bollinger_bands(15, 180, 30, KEY)
        @test ~isempty(all_traces)

        for trace in all_traces
            @test trace.fields[:y] |> length == 180
        end

    end

end

@testset "plot_candle_vol_data" begin

    apply(patch) do
        
        all_traces = CryptoDashApp.plot_candle_vol_data(7, 180, KEY)
        @test ~isempty(all_traces)

        # Check candlestick data
        candle_trace = all_traces[1]

        for candle in [:high, :low, :open, :close]
            @test candle_trace.fields[candle] |> length == 180
        end

        bar_trace = all_traces[2]
        @test bar_trace.fields[:y] |> length == 180

    end

end

@testset "plot_cumul_daily_return_hist" begin

    apply(patch) do

        all_traces = CryptoDashApp.plot_cumul_daily_return_hist(11, 60, KEY)
        @test ~isempty(all_traces)

        # Cumulative return
        @test all_traces[1].fields[:y] |> length == 59

        # Green and red returns will change with time, hence cannot be tested here

        # Daily change histogram
        # @test all_traces[4].fields[:y] |> length == 78

    end

end

@testset "plot_macd_signal" begin

    apply(patch) do

        all_traces = CryptoDashApp.plot_macd_signal(20, 42, KEY)
        @test ~isempty(all_traces)

        for trace in all_traces
            trace.fields[:y] |> length == 43
        end

    end
    
end

@testset "plot_linear_regression" begin

    apply(patch) do

        all_traces = CryptoDashApp.plot_linear_regression(15, 200, KEY)
        @test ~isempty(all_traces)

        for trace in all_traces[1:4]
            @test trace.fields[:y] |> length == 200
        end

    end

end