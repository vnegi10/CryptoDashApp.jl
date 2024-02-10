function get_API_response(params::String, url::String)

    cg_headers = Dict("accept" => "application/json",
                      "x-cg-demo-api-key" => CG_KEY)

    if occursin("coingecko", url)
        request = HTTP.request("GET",
                               url * params,
                               cg_headers;
                               verbose = 0,
                               retries = 2)
    else
        request = HTTP.request("GET",
                                url * params;
                                verbose = 0,
                                retries = 2)
    end

    response_text = String(request.body)
    response_dict = JSON.parse(response_text)

    return response_dict
end