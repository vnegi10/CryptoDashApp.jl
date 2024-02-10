################# URLs for API requests #################

const CG_URL = "https://api.coingecko.com/api/v3"
const AV_URL = "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY"

################# API keys #################

if haskey(ENV, "KEY_AV")
    const KEY = ENV["KEY_AV"]
else
    error("API key for AlphaVantage has not been provided!")
end

if haskey(ENV, "KEY_CG")
    const CG_KEY = ENV["KEY_CG"]
else
    error("API key for CoinGecko has not been provided!")
end