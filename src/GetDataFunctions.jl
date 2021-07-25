function get_price_data_single(currency::String)
    
    date = Dates.today()

    filename = "$(currency)_EUR_data_$(date).csv"
    filepath = joinpath("data", filename)

    raw_df = DataFrame()

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile(filepath)
        @info "Reading $(currency) price/vol data from CSV file on disk"
        raw_df = CSV.File(filepath) |> DataFrame        
    else
        try 
            @info "Fetching $(currency) price/vol data from Alpha Vantage"  
            raw = AlphaVantage.digital_currency_daily(currency, "EUR", datatype="csv") 
            raw_df = raw_to_df(raw) 
            CSV.write(filepath, raw_df)           
        catch
            @info "Could not fetch data, try again later!"          
        end         
    end 
    
    # Return processed DataFrame only when raw data has been fetched successfully
    if ~isempty(raw_df)    
        df_out_price, df_out_candle = average_price_df(currency, raw_df)
        df_out_vol = vol_df(currency, raw_df)    

        return df_out_price, df_out_candle, df_out_vol
    else
        return DataFrame[], DataFrame[], DataFrame[]
    end
end

function get_ratings_data(currency::String)

    date = Dates.today()
    
    filename = "$(currency)_metrics_data_$(date).csv"
    filepath = joinpath("data", filename)

    metrics_df = DataFrame()

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile(filepath)
        @info "Reading $(currency) FCAS data from CSV file on disk"
        metrics_df = CSV.File(filepath) |> DataFrame
    else
        try
            @info "Fetching $(currency) FCAS data from Alpha Vantage"  
            rating = AlphaVantage.crypto_rating(currency)
            scores = rating["Crypto Rating (FCAS)"]
            CSV.write(filepath, scores)
            metrics_df = CSV.File(filepath) |> DataFrame
        catch err
            if isa(err, KeyError)
                @info "Could not retrieve data. Something wrong with the API, try again later!"
            else
                @info "This is a new error: $(err)"
            end            
        end        
    end        

    ratings = ["utility", "fcas score", "developer", "market", "fcas rating"]
    index = Array{Int64}(undef,0)

    # Return scores only when metrics data has been fetched successfully
    if ~isempty(metrics_df)
        
        # Find the row(index) of a string match
        for rating in ratings
            i = findall(occursin.(rating, metrics_df[!,1]))
            push!(index, i[1])
        end    
        
        # Variables should be assigned in the same order as the list of ratings above
        utility_score, fcas_score, dev_score = metrics_df[!,2][index[1]], metrics_df[!,2][index[2]], metrics_df[!,2][index[3]]
        mark_score, fcas_rating = metrics_df[!,2][index[4]], metrics_df[!,2][index[5]]
        
        return utility_score, fcas_score, dev_score, mark_score, fcas_rating
    else
        return Number[], Number[], Number[], Number[], Number[]
    end

end