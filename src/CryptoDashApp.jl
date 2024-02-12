module CryptoDashApp

export run_app,
       load_keys

using DataFrames,
      Dates,
      PlotlyJS,
      Dash,
      CSV,
      Statistics,
      StatsBase,
      GLM,
      HTTP,
      JSON,
      Mocking

include("constants.jl")
include("app.jl")

include("getdataAV.jl")
include("getdataCG.jl")

include("plotsAV.jl")
include("plotsCG.jl")

include("request.jl")
include("helpers.jl")

end # module