################# Test cases for CoinGecko API  #################

@testset "Check for exception handling while determining coin id" begin

    @test_throws ErrorException("Could not find an id for the given currency") CryptoDashApp.get_coin_id("dummy")

end