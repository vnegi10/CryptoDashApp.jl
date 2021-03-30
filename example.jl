#= Revise.jl allows code modification and use without restarting Julia. Load this package when
  you want to make changes to the app =#
# using Revise

# To download all necessary packages when using for the first time, instantiate the environment.
# using Pkg; Pkg.instantiate()

using CryptoDashApp

run_app(8056, "your key") # where 8056 is the port

# Now, open a new tab and check if you can access http://0.0.0.0:8056/ or http://127.0.0.1:8056/
