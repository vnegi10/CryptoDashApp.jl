module CryptoDashApp

export run_app

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
      DelimitedFiles,
      Mocking

include("app.jl")

include("getdataAV.jl")
include("getdataCG.jl")

include("plotsAV.jl")
include("plotsCG.jl")

include("request.jl")
include("helpers.jl")

end # module