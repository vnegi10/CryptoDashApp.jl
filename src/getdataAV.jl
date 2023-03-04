################# Functions for AlphaVantage API #################

function get_price_data_single(currency::String)

    date = Dates.today()

    filename = "$(currency)_EUR_data_$(date).csv"
    filepath = joinpath(@__DIR__, "..", "data", filename)

    df_raw = DataFrame()

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile(filepath)
        @info "Reading $(currency) price/vol data from CSV file on disk"
        df_raw = CSV.File(filepath) |> DataFrame
    else
        try
            @info "Fetching $(currency) price/vol data from Alpha Vantage"
            raw = AlphaVantage.digital_currency_daily(currency, "EUR", datatype = "csv")
            df_raw = raw_to_df(raw)
            CSV.write(filepath, df_raw)
        catch
            @info "Could not fetch data, try again later!"
        end
    end

    # Return processed DataFrame only when raw data has been fetched successfully
    if ~isempty(df_raw)
        df_out_price, df_out_candle = average_df_price(currency, df_raw)
        df_out_vol = df_vol(currency, df_raw)

        return df_out_price, df_out_candle, df_out_vol
    else
        return DataFrame[], DataFrame[], DataFrame[]
    end
end