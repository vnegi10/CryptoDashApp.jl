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
        df_filter = filter(row -> ~ismissing(row.symbol) &&
                                   row.symbol == currency, df_coins)

        try
            # For multiple matches, first filter on coin ids and then on names,
            # which do not have "-" in them
            if size(df_filter)[1] > 1

                df_filter_1 = filter(row -> ~ismissing(row.id) &&
                                            ~occursin("-", row.id), df_filter)

                if isempty(df_filter_1)
                    df_filter_1 = filter(row -> ~ismissing(row.name) &&
                                                ~occursin("-", row.name), df_filter)
                end

                return df_filter_1[!, :id][1]
            end

            return df_filter[!, :id][1]

        catch err
            if isa(err, BoundsError)
                error("Could not find an id for the given currency")
            else
                error("Something went wrong, check this error: $(err)")
            end
        end

    else
        return ""
    end
end

function dict_to_df(data_dict::Dict, df::DataFrame)

    # Collect only the key-value data which is suitable for plotting
    for key in collect(keys(data_dict))
        if ~isnothing(data_dict[key]) && length(data_dict[key]) == 1
            push!(df, [key Float64(data_dict[key])])
        end
    end

    return df
end

function get_dev_comm_data(currency::String)

    coin_id = get_coin_id(currency)

    coin_dict, dev_dict, comm_dict = [Dict() for i = 1:3]

    try
        @info "Fetching coin data from CoinGecko"
        coin_dict = get_API_response("/coins/$(coin_id)")
    catch
        error("Could not fetch data, try again later!")
    end

    # Get developer data
    try
        dev_dict = coin_dict["developer_data"]
    catch err
        if isa(err, KeyError)
            @error "Could not find developer data!"
        else
            @error "This is a new error: $(err)"
        end
    end

    # Get community data
    try
        comm_dict = coin_dict["community_data"]
    catch err
        if isa(err, KeyError)
            @error "Could not find community data!"
        else
            @error "This is a new error: $(err)"
        end
    end

    # Convert dict to DataFrame
    df_dev, df_comm = [DataFrame(Metric = String[], Value = Float64[]) for i = 1:2]

    if ~isempty(dev_dict)
        df_dev = dict_to_df(dev_dict, df_dev)
    end

    if ~isempty(comm_dict)
        df_comm = dict_to_df(comm_dict, df_comm)
    end

    return df_dev, df_comm
end

function get_list_of_exchanges(num_exchanges::Int64)

    date = Dates.today()

    filename = "List_of_top_$(num_exchanges)_exchanges_$(date).csv"
    filepath = joinpath("data", filename)

    df_all_ex, df_ex = [DataFrame() for i = 1:2]

    # Look for present day's CSV file, if not found, download and save data to a new file
    if isfile(filepath)
        @info "Reading list of exchanges from CSV file on disk"
        df_ex = CSV.File(filepath) |> DataFrame
    else
        try
            @info "Fetching list of exchanges from CoinGecko"
            ex_dict   = get_API_response("/exchanges")
            df_all_ex = vcat(DataFrame.(ex_dict)...)

            # Keep only name and id columns
            df_ex = DataFrame(Name = df_all_ex[!, :name],
                              ID   = df_all_ex[!, :id])
            CSV.write(filepath, df_ex)
        catch err
            @error "Could not fetch data, try again later!"
            @error "$(err)"
        end
    end

    # Return filtered list of exchanges only when data is available
    if ~isempty(df_ex)
        return df_ex[1:num_exchanges, :]
    else
        return DataFrame()
    end
end

function get_exchange_vol_data(currency::String, num_exchanges::Int64)

    coin_id = get_coin_id(currency)

    df_ex_vol = get_list_of_exchanges(num_exchanges)
    allowmissing!(df_ex_vol)

    exchange_coin_vol, exchange_usd_vol = [Union{Missing,Float64}[] for i = 1:2]

    # Extract volume data only when a list of exchanges is available
    if ~isempty(df_ex_vol)

        for exchange in df_ex_vol[!, :ID]

            coin_vol, usd_vol = [Float64[] for i = 1:2]
            coin_vol_tickers_dict = Dict()

            try
                coin_vol_tickers_dict =
                    get_API_response("/exchanges/$(exchange)/tickers?coin_ids=$(coin_id)")
            catch err
                @info "Could not find $(coin_id) volume data on $(exchange)!"
                @info "$(err)"
            end

            if ~isempty(coin_vol_tickers_dict)

                for ticker in coin_vol_tickers_dict["tickers"]
                    push!(coin_vol, ticker["volume"])
                    push!(
                        usd_vol,
                        ticker["converted_volume"]["usd"],
                    )
                end

                push!(exchange_coin_vol, sum(coin_vol))
                push!(exchange_usd_vol, sum(usd_vol))

            else
                push!(exchange_coin_vol, missing)
                push!(exchange_usd_vol, missing)
            end

        end
    end

    insertcols!(
        df_ex_vol,
        3,
        :Coin_volume => exchange_coin_vol,
        :USD_volume => exchange_usd_vol,
    )

    return df_ex_vol
end

function get_vol_chart(exchange::String)

    date = Dates.today()

    filename = "$(exchange)_vol_data_$(date).txt"
    filepath = joinpath("data", filename)

    ex_vol_chart = Vector{Any}[]

    # Historical data is fetched and saved for these many days. Takes more time for longer duration, 
    # and queries for many exchanges don't even return more points.
    days = 365

    if isfile(filepath)
        @info "Reading $(exchange) vol data from file on disk"
        ex_vol_chart = readdlm(filepath, ';')

        # Drop the dimension and convert to Float64
        ex_vol_chart = Float64.(ex_vol_chart[:])
    else
        try
            # Fetch and save data for 365 days
            ex_vol_chart =
                get_API_response("/exchanges/$(exchange)/volume_chart?days=$(days)")

            open(filepath, "w") do f
                for chart in ex_vol_chart
                    writedlm(f, [chart], ";")
                end
            end

        catch err
            @info "Could not find volume data for $(exchange)"
            @info "$(err)"
        end
    end

    if length(ex_vol_chart) > days
        start_index = Int64(length(ex_vol_chart) / 2) + 1
        return ex_vol_chart[start_index:end]

    else
        ex_vol = Union{Missing,Float64}[]

        for chart in ex_vol_chart
            try
                push!(ex_vol, round(parse(Float64, chart[2]); digits = 2))
            catch
                push!(ex_vol, missing)
            end
        end

        return ex_vol
    end
end

function get_overall_vol_data(duration::Int64, num_exchanges::Int64)

    df_ex_list = get_list_of_exchanges(num_exchanges)

    # Check on duration, current maximum is set to 365
    if duration > 365
        duration = 365
    end

    # Create a column with dates
    f_day = Dates.today()
    i_day = f_day - Dates.Day(duration - 1)

    time = collect(i_day:Dates.Day(1):f_day)

    df_ex_vol = DataFrame(Time = time)
    allowmissing!(df_ex_vol)

    # Extract volume data only when a list of exchanges is available
    if ~isempty(df_ex_list)

        for exchange in df_ex_list[!, :ID]

            ex_vol = Vector{Any}[]

            try
                ex_vol = get_vol_chart(exchange)
            catch err
                @info "Could not find volume data for $(exchange), will continue to next!"
                @info "$(err)"

                # Skip next part of the code, and continue to next exchange
                continue
            end

            # Check and filter on duration 
            if duration > length(ex_vol)
                duration = length(ex_vol)
            end
            ex_vol = ex_vol[end-duration+1:end]

            # Find name of the exchange corresponding to its ID
            df_row = df_ex_list |> @filter(_.ID == exchange) |> DataFrame
            name = df_row[!, :Name][1]

            try
                insertcols!(df_ex_vol, 2, Symbol(name) => ex_vol)
            catch err
                if isa(err, DimensionMismatch)
                    @info "Data is missing for $(exchange) for the requested duration"
                else
                    @info "Something went wrong, check this error: $(err)"
                end
            end

        end

        return df_ex_vol
    else
        return DataFrame()
    end

end