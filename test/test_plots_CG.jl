################# Test cases for plots using CoinGecko data #################

@testset "plot_dev_comm_data" begin

    all_traces = CryptoDashApp.plot_dev_comm_data(7)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_exchange_vol_data" begin

    all_traces = CryptoDashApp.plot_exchange_vol_data(7)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end

@testset "plot_overall_vol_data" begin

    all_traces = CryptoDashApp.plot_overall_vol_data(30)

    for trace in all_traces
        @test ~isempty(trace)
        @test typeof(trace) == PlotlyBase.GenericTrace{Dict{Symbol, Any}}
    end   

end