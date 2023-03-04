################# Test cases for CoinGecko API  #################

@testset "Check if CG developer and community data are accessible" begin

    for currency in ["eth"]

        df_dev, df_comm = CryptoDashApp.get_dev_comm_data(currency)

        @test ~isempty(df_dev)
        @test ~isempty(df_comm)

    end

end

@testset "Check if CG exchange volume data per currency are accessible" begin

    for currency in ["btc"]

        num_exchanges = 5

        df_ex_vol = CryptoDashApp.get_exchange_vol_data(currency, num_exchanges)

        @test size(df_ex_vol)[1] == num_exchanges

    end

end

@testset "Check if CG overall exchange volume data are accessible" begin

    num_exchanges = 5

    for duration in [10, 30]
        df_ex_vol = CryptoDashApp.get_overall_vol_data(duration, num_exchanges)

        # Check for rows
        @test size(df_ex_vol)[1] == duration

        # Check for columns, total is num_exchanges + 1 due to "Time" column
        @test size(df_ex_vol)[2] == num_exchanges + 1
    end

end