################# URLs for API requests #################

const CG_URL = "https://api.coingecko.com/api/v3"
const AV_URL = "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY"

################# API keys #################

AV_KEY = "dummy"
CG_KEY = "dummy"

function load_keys()

    if haskey(ENV, "KEY_AV")
        global AV_KEY = ENV["KEY_AV"]
    else
        @warn("API key for AlphaVantage has not been provided!")
    end

    if haskey(ENV, "KEY_CG")
        global CG_KEY = ENV["KEY_CG"]
    else
        @warn("API key for CoinGecko has not been provided!")
    end

    return nothing

end