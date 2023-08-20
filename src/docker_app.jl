using Pkg
Pkg.activate(pwd())

using CryptoDashApp
key = ENV["env_key"]
run_app(8010, key)