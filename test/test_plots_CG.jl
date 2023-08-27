################# Test cases for plots using CoinGecko data #################

@testset "plot_dev_comm_data" begin

    apply(patch_2) do

        all_traces = CryptoDashApp.plot_dev_comm_data(7)
        @test ~isempty(all_traces)

        @test all_traces[1].fields[:y] |> length == 8
        @test all_traces[2].fields[:y] |> length == 5

    end

end

@testset "plot_exchange_vol_data" begin

    apply(patch_3) do

        all_traces = CryptoDashApp.plot_exchange_vol_data(7, 10)
        @test ~isempty(all_traces)

        for trace in all_traces
            @test trace.fields[:y] |> length == 10
        end

    end

end

@testset "plot_overall_vol_data" begin

    apply(patch_4) do

        all_traces = CryptoDashApp.plot_overall_vol_data(30, 10)
        @test ~isempty(all_traces)

        for trace in all_traces
            @test trace.fields[:y] |> length == 30
        end

    end

end