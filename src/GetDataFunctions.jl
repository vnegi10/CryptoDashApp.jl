function get_price_data_single(currency::String)
    
    df_out_price, df_out_vol, df_out_candle  = [DataFrame() for i = 1:3]    
    date = Dates.today()

    main_dir = pwd()   
    cd("data")

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile("$(currency)_EUR_data_$(date).csv")
        @info "Reading $(currency) price/vol data from CSV file on disk"
        global raw_df = CSV.File("$(currency)_EUR_data_$(date).csv") |> DataFrame        
    else
        try 
            @info "Fetching $(currency) price/vol data from Alpha Vantage"  
            raw = AlphaVantage.digital_currency_daily(currency, "EUR", datatype="csv") 
            global raw_df = raw_to_df(raw) 
            s2 = "$(currency)_EUR_data_$(date).csv"                   
            CSV.write(s2, raw_df)           
        catch
            println("Could not fetch data, try again later!")
            cd(main_dir)
        end         
    end  
    
    cd(main_dir)
    average_price_df(currency, raw_df, df_out_price, df_out_candle)
    vol_df(currency, raw_df, df_out_vol)    

    return df_out_price, df_out_candle, df_out_vol
end

function get_ratings_data(currency::String)

    date = Dates.today()
    main_dir = pwd()
    cd("data")

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile("$(currency)_metrics_data_$(date).csv")
        @info "Reading $(currency) FCAS data from CSV file on disk"
        global metrics_df = CSV.File("$(currency)_metrics_data_$(date).csv") |> DataFrame
    else
        try
            @info "Fetching $(currency) FCAS data from Alpha Vantage"  
            rating = AlphaVantage.crypto_rating(currency)
            scores = rating["Crypto Rating (FCAS)"]
            s2 = "$(currency)_metrics_data_$(date).csv"
            CSV.write(s2, scores)
            global metrics_df = CSV.File("$(currency)_metrics_data_$(date).csv") |> DataFrame
        catch err
            if isa(err, KeyError)
                println("Could not retrieve data. Something wrong with API, try again later!")
            else
                println("This is a new error: $(err)")
            end
            cd(main_dir)
        end        
    end    

    cd(main_dir)

    ratings = ["utility", "fcas score", "developer", "market", "fcas rating"]
    index = Array{Int64}(undef,0)

    # Find the row(index) of a string match
    for rating in ratings
        i = findall(occursin.(rating, metrics_df[!,1]))
        push!(index, i[1])
    end    
    
    # Variables should be assigned in the same order as the list of ratings above
    utility_score, fcas_score, dev_score = metrics_df[!,2][index[1]], metrics_df[!,2][index[2]], metrics_df[!,2][index[3]]
    mark_score, fcas_rating = metrics_df[!,2][index[4]], metrics_df[!,2][index[5]]
    
    return utility_score, fcas_score, dev_score, mark_score, fcas_rating
end