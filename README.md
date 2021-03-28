## CryptoDashApp

Interactive visualization of historical price, health metrics, candlestick and volume data for various cryptocurrencies. Data are obtained via API queries to Alpha Vantage. 
The app is written in Julia and makes use of Dash.jl along with its react framework to generate a dashboard style view accessible via a browser. 
Different moving averages are also calculated and plotted along with the daily average price data. Averaging window can be selected by the user.

Functionality of the app will be extended in the future by adding more technical indicators.

## How to use?

Clone this repo to your local system. Open Julia REPL and cd to the repo directory. Now activate the project environment by doing the following:
* Press ']' to enter Pkg prompt
* Type **activate .**
* Type **instantiate**

Once the environment is activated, you can make use of the **CryptoDashApp** module

    using CryptoDashApp
    run_app(8056, "your key") # where 8056 is the port 
    
Now, open a new tab and check if you can access http://0.0.0.0:8056/
    



    


