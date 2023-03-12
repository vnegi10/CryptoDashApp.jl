################# Test cases for moving averages #################

@testset "Check if MA, MACD + signal, σ (for Bollinger bands) are calculated" begin

    for currency in ["DOT"]

        df_out_price, _, _ = CryptoDashApp.get_price_data_single(currency, KEY)

        duration = 90
        window = 30

        price_SMA, price_WMA, price_EMA =
            CryptoDashApp.moving_averages(df_out_price, duration, window)

        @test ~isempty(price_SMA)
        @test ~isempty(price_WMA)
        @test ~isempty(price_WMA)

        df_out_price = df_out_price[end-duration+1-26-9+1:end, :]
        df_ema_all = CryptoDashApp.calculate_macd(df_out_price)
        @test ~isempty(df_ema_all)

        Price_σ = CryptoDashApp.moving_std(df_out_price, duration, window)
        @test ~isempty(Price_σ)

    end

end