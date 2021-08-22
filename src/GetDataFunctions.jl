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


################# Functions for CoinGecko API #################

function get_API_response(params::String, url::String = URL)
	
	CG_request = HTTP.request("GET", url * params; verbose = 0, retries = 2)
	response_text = String(CG_request.body)
	response_dict = JSON.parse(response_text)
	
	return response_dict
end

function get_coin_id(currency::String)

    date = Dates.today()

    filename = "List_of_all_coins_$(date).csv"
    filepath = joinpath("data", filename)

    df_coins, df_filter, df_filter_1 = [DataFrame() for i = 1:3]

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile(filepath)
        @info "Reading list of coins from CSV file on disk"
        df_coins = CSV.File(filepath) |> DataFrame        
    else
        try 
            @info "Fetching list of coins from CoinGecko"  
            coins_dict = get_API_response("/coins/list")
            df_coins = vcat(DataFrame.(coins_dict)...) 
            CSV.write(filepath, df_coins)           
        catch
            @info "Could not fetch data, try again later!"          
        end         
    end 

    # Return valid coin id only when list of coins is available
    if ~isempty(df_coins)

        # Filter on matching currency 
        df_filter = df_coins |> @filter(_.symbol == currency) |> DataFrame

        # For multiple matches, first filter on coin ids and then on names,
        # which do not have "-" in them
        if size(df_filter)[1] > 1

            df_filter_1 = df_filter |> 
                        @filter(~occursin("-", _.id)) |> DataFrame

            if isempty(df_filter_1)
                df_filter_1 = df_filter |> 
                        @filter(~occursin("-", _.name)) |> DataFrame
            end

            return df_filter_1[!, :id][1]
        end
        
        return df_filter[!, :id][1]
    else
        return ""   
    end
end

function get_dev_data(currency::String)

    coin_id = get_coin_id(currency)

    coin_dict, dev_dict = Dict(), Dict()

    try
        @info "Fetching coin data from CoinGecko" 
        coin_dict = get_API_response("/coins/$(coin_id)")        
    catch
        @info "Could not fetch data, try again later!" 
    end

    try
        dev_dict = coin_dict["developer_data"]
    catch err     
        if isa(err, KeyError)
            @info "Could not find developer data!"
        else
            @info "This is a new error: $(err)"
        end
    end

    df_dev = DataFrame(Metric = String[], Value = Int64[])

    if ~isempty(coin_dict) && ~isempty(dev_dict)   
        
        # Collect only the key-value data which is suitable for plotting	
        for key in collect(keys(dev_dict))            
            if length(dev_dict[key]) == 1
                push!(df_dev, [key Int(dev_dict[key])])
            end		
        end	
    end

    return df_dev
end
        
        

    





    



    