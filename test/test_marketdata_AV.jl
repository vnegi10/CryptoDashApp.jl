################# Test cases for accessing market data #################

@testset "Check if AV market data are accessible" begin

    for currency in ["BTC"]

        df_out_price, df_out_candle, df_out_vol =
            CryptoDashApp.get_price_data_single(currency, AV_KEY)

        @test ~isempty(df_out_price)
        @test ~isempty(df_out_candle)
        @test ~isempty(df_out_vol)

    end

end

@testset "Check for exception handling while accessing AV market data" begin

    currency = "dummy"

    @test_throws ErrorException("Could not fetch data, try again later!") CryptoDashApp.get_price_data_single(
        currency,
        AV_KEY
    )

end