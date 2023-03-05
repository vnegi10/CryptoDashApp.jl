function get_API_response(params::String, url::String)

    request       = HTTP.request("GET", url * params; verbose = 0, retries = 2)
    response_text = String(request.body)
    response_dict = JSON.parse(response_text)

    return response_dict
end