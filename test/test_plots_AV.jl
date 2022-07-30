################# Test cases for plots using AlphaVantage data #################

@testset "plot_price_ma_trade_data" begin

    all_traces = CryptoDashApp.plot_price_ma_trade_data(7, 180, 30)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_price_bollinger_bands" begin

    all_traces = CryptoDashApp.plot_price_bollinger_bands(13, 180, 30)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_candle_vol_data" begin

    all_traces = CryptoDashApp.plot_candle_vol_data(18, 180)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_cumul_daily_return_hist" begin

    all_traces = CryptoDashApp.plot_cumul_daily_return_hist(12, 180)

    for trace in all_traces[1:4]
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_fcas_data" begin

    trace1 = CryptoDashApp.plot_fcas_data(13)[1]

    # Unable to get FCAS metrics from AV, so skipping tests for now [30-07-2022]
    @test_skip ~isempty(trace1)
    @test_skip typeof(trace1) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}       

end

@testset "plot_macd_signal" begin

    all_traces = CryptoDashApp.plot_macd_signal(2, 180)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_linear_regression" begin

    all_traces = CryptoDashApp.plot_linear_regression(17, 180)

    for trace in all_traces[1:4]
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end