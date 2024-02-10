################# Test cases for plots using AlphaVantage data #################

@testset "plot_price_ma_trade_data" begin

    apply(patch_1) do

        all_traces = CryptoDashApp.plot_price_ma_trade_data(10, 90, 30, AV_KEY)
        @test ~isempty(all_traces)

        for trace in all_traces
            @test trace.fields[:y] |> length == 90
        end

    end

end

@testset "plot_price_bollinger_bands" begin

    apply(patch_1) do

        all_traces = CryptoDashApp.plot_price_bollinger_bands(15, 180, 30, AV_KEY)
        @test ~isempty(all_traces)

        for trace in all_traces
            @test trace.fields[:y] |> length == 180
        end

    end

end

@testset "plot_candle_vol_data" begin

    apply(patch_1) do
        
        all_traces = CryptoDashApp.plot_candle_vol_data(7, 180, AV_KEY)
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

    apply(patch_1) do

        all_traces = CryptoDashApp.plot_cumul_daily_return_hist(11, 60, AV_KEY)
        @test ~isempty(all_traces)

        # Cumulative return
        @test all_traces[1].fields[:y] |> length == 59

        # Green and red returns will change with time, hence cannot be tested here

        # Daily change histogram
        # @test all_traces[4].fields[:y] |> length == 78

    end

end

@testset "plot_macd_signal" begin

    apply(patch_1) do

        all_traces = CryptoDashApp.plot_macd_signal(20, 42, AV_KEY)
        @test ~isempty(all_traces)

        for trace in all_traces
            trace.fields[:y] |> length == 43
        end

    end
    
end

@testset "plot_linear_regression" begin

    apply(patch_1) do

        all_traces = CryptoDashApp.plot_linear_regression(15, 200, AV_KEY)
        @test ~isempty(all_traces)

        for trace in all_traces[1:4]
            @test trace.fields[:y] |> length == 200
        end

    end

end