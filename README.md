## CryptoDashApp

Interactive visualization of historical price, health metrics, candlestick and volume data for various cryptocurrencies. Data are obtained via API queries to Alpha Vantage. 
The app is written in Julia and makes use of Dash.jl along with its react framework to generate a dashboard style view accessible via a browser. 
Different moving averages are also calculated and plotted along with the daily average price data. Averaging window can be selected by the user.

Functionality of the app will be extended in the future by adding more technical indicators.

## How to use?

Clone this repo to your local system. Open Julia REPL and cd to the repo directory. Now activate + instantiate the project environment by doing the following:
* Press ']' to enter Pkg prompt
* Type **activate .**
* Type **instantiate**

Alternatively, with VS Code, simply selecting the repo folder should activate the correct environment. You can also instantiate from a script (see example.jl) by executing:
    using Pkg; Pkg.instantiate()

Once all the packages are downloaded, you can make use of the **CryptoDashApp** module from the REPL itself or within a script by executing:

    using CryptoDashApp
    run_app(8056, "your key") # where 8056 is the port 
    
Now, open a new tab in your browser and check if you can access http://0.0.0.0:8056/ or http://127.0.0.1:8056/

First plot will take a few seconds to appear, wait patiently! If you are running this app for the first time, or on a different date, new data will be retrieved from Alpha Vantage, and then saved to CSV files on disk. Keep in mind that the free API key imposes a limit of five calls/minute, which means you won't be able to load data for more than five currencies in quick succession. In case you see an error, wait for a while and then try again.


    



    


