General idea:
The goal for creating figures is to give us a straightfowrad view about the market changes and provide us a “shortcut” to identify some suspicious trading patterns
You can check the figure folder for some results. However, the raw data will not be provided here. 

The figure contains two parts: 
1. gradient color represents depth change. 
2. triangles represent trades happened. Larger the triangle is, larger the number of trades happen at that 1 milliseconds.


Steps:
1. Merge csv files that are in the same trade day and belong to same futures into one excel file
2. Use trade_summary.py to extract all executions.
3. Some time, we may find that plot the depth for all price will be very confused so we can focus on the 10-level buy and sell depths.
Use n_depth_update.py to get 10-level depth data row by row from raw data.(or any number of level you want to plot on figures), output a csv file
4. Use dynamic_size.py, input the trade summary and output what triangle size this trade should be based on its log value. Output to trade_log csv files
5. Use general_process_for_figures.R to generate the figures, input two things: i. the n_depth csv from 2 step. ii. the trade_log csv from 4 step