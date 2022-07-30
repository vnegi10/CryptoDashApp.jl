################# Test cases for plots using AlphaVantage data #################

@testset "plot_price_ma_trade_data" begin

    all_traces = CryptoDashApp.plot_price_ma_trade_data(7, 90, 30)
    @test ~isempty(all_traces)

    for trace in all_traces
        @test trace.fields[:y] |> length == 90
    end   

end

@testset "plot_price_bollinger_bands" begin

    all_traces = CryptoDashApp.plot_price_bollinger_bands(13, 180, 30)
    @test ~isempty(all_traces)

    for trace in all_traces
        @test trace.fields[:y] |> length == 180
    end   

end

@testset "plot_candle_vol_data" begin

    all_traces = CryptoDashApp.plot_candle_vol_data(18, 180)
    @test ~isempty(all_traces)

    # Check candlestick data
    candle_trace = all_traces[1]

    for candle in [:high, :low, :open, :close]
        @test candle_trace.fields[candle] |> length == 180
    end

    bar_trace = all_traces[2]
    @test bar_trace.fields[:y] |> length == 180    

end

@testset "plot_cumul_daily_return_hist" begin

    all_traces = CryptoDashApp.plot_cumul_daily_return_hist(12, 60)
    @test ~isempty(all_traces)

    # Cumulative return
    @test all_traces[1].fields[:y] |> length == 59

    # Green and red returns will change with time, hence cannot be tested here

    # Daily change histogram
    @test all_traces[4].fields[:y] |> length == 78      

end

@testset "plot_fcas_data" begin

    trace1 = CryptoDashApp.plot_fcas_data(13)[1]

    # Unable to get FCAS metrics from AV, so skipping tests for now [30-07-2022]
    @test_skip ~isempty(trace1)
    @test_skip typeof(trace1) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}       

end

@testset "plot_macd_signal" begin

    all_traces = CryptoDashApp.plot_macd_signal(2, 42)
    @test ~isempty(all_traces)

    for trace in all_traces
        trace.fields[:y] |> length == 43
    end
    
end

@testset "plot_linear_regression" begin

    all_traces = CryptoDashApp.plot_linear_regression(17, 200)
    @test ~isempty(all_traces)

    for trace in all_traces[1:4]
        @test trace.fields[:y] |> length == 200
    end   

end