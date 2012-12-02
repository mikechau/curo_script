require 'date'

###### SEED DATA ###### 

transactions = [
								{:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
								{:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 5.00, :acc_for => 'no'},
								{:date => '2011-04-17', :action => "BUY", :ticker => "AAPL", :price => 10.00, :qty => 5.00, :acc_for => 'no' },
								{:date => '2011-04-19', :action => "SELL", :ticker => "AAPL", :price => 10.00, :qty => 20.00, :acc_for => 'no'},
								{:date => '2011-04-22', :action => "SELL", :ticker => "AAPL", :price => 15.00, :qty => 5.00, :acc_for => 'no'}
							 ]

eod_prices = [
							{:date => '2011-04-15', :ticker => "AAPL", :eod_price => 9.00},
							{:date => '2011-04-16', :ticker => "AAPL", :eod_price => 10.00},
							{:date => '2011-04-17', :ticker => "AAPL", :eod_price => 11.00},
							{:date =>'2011-04-18', :ticker => "AAPL", :eod_price => 12.00},
							{:date => '2011-04-19', :ticker => "AAPL", :eod_price => 11.00},
							{:date => '2011-04-20', :ticker => "AAPL", :eod_price => 13.00},
							{:date => '2011-04-21', :ticker => "AAPL", :eod_price => 12.00},
							{:date => '2011-04-22', :ticker => "AAPL", :eod_price => 14.00},
							{:date => '2011-05-01', :ticker => "AAPL", :eod_price => 17.00},
							{:date => '2011-05-02', :ticker => "AAPL", :eod_price => 19.00},
							{:date => '2011-05-03', :ticker => "AAPL", :eod_price => 22.00},
							{:date => '2011-05-21', :ticker => "AAPL", :eod_price => 31.00},
							{:date => '2011-06-04', :ticker => "AAPL", :eod_price => 10.00},
						 ]

###### EMPTY ARRAYS ###### 

open_positions = []

market_status_array = []
trades_array = []

###### Taking arrays to create a main array to work with ###### 

#loop through the transactions array
transactions.each_with_index do |trade, index|

	# shovel the transactions hash without :acc_for hash into trades_array
	trades_array << {:date => trade[:date], :desc => trade[:action], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty]}

	if trade[:action] == "BUY"
		# puts "[BUY] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"

		#check if Buy exists in open_positions array, if not add to array
		if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price]}
			match_position = open_positions.find {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:date] == trade[:date]}
			op_lock = open_positions.index(match_position)
			open_positions[op_lock][:qty] += trade[:qty]
			trade[:acc_for] = 'yes'
		else
			open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty]}
		end

		#check if the ticker exists in the market data table
		if eod_prices.any? {|t| t[:ticker] == trade[:ticker]}

			#finds the first sell date that has not been marked
			if transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == "SELL" && t[:acc_for] == 'no'}
				stop_date = transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == "SELL" && t[:acc_for] == 'no'}

				#set end_day to the SELL transaction that has not been marked by :acc_for
				end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date]) && Date.parse(t[:date]) < Date.parse(stop_date[:date])}
				#end_day_count = end_day.count

				#puts "[BUY] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"

				#runs through the array pulled from .select and prints the market prices
				# eventually shovel into new array to organize w/ other stocks
				end_day.each_with_index do |history, index|
					#puts "[MRKT] => #{history[:date]} || TICKER: #{history[:ticker]} || PRICE: #{history[:eod_price]}"

					market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price]}
				end

				# marks the SELL transaction :acc_for to 'yes'
				transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == "SELL" && t[:acc_for] == 'no'}[:acc_for] = 'yes'
		
			# there are no 'SELL' actions, continue displaying market prices
			elsif transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == "BUY"} && trade[:acc_for] == 'no'
				#puts "[BUY] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"

				end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date])}
				
				end_day.each_with_index do |history, index|
				
					#puts "[MRKT] => #{history[:date]} || TICKER: #{history[:ticker]} || PRICE: #{history[:eod_price]}"
					market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price]}

				end

			else
				#puts "[BUY] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"
			end

		end

	elsif trade[:action] == "SELL"
		#puts "[SELL] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"
		# open positions needs to be revised to track date of position
		if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:date] == trade[:date]}
			op_qty = open_positions.find {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:date] == trade[:date]}[:qty]
			op_qty -= trade[:qty]

		elsif open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] < trade[:qty]}
			op_select = open_positions.select {|o| o[:ticker] == trade[:ticker] && Date.parse(o[:date]) >= Date.parse(trade[:date])}
			qty_sold = trade[:qty]
			op_select.each do |op|
				if op[:qty] > 0
					remainder = qty_sold - op[:qty]
					op_decrease = qty_sold - remainder
					op[:qty] -= op_decrease

					qty_sold = remainder
				end
			end
		else
			puts 'Error: Open Position did not exist!'
		end
	else
		puts 'Error: Action is not "BUY" or "SELL" '
	end
end

# clean up the arrays into trades_array

market_status_array = market_status_array.uniq

trades_array += market_status_array
trades_array.sort! { |x, y| x[:date] <=> y[:date]}

negative_sells = trades_array.select {|t| t[:desc] == 'SELL'}
negative_sells.each do |trade|
	trade[:qty] *=-1
end

###### VARIABLES ###### 

nav_units = 1000.0
cash_balance = 2000.0
stock_balance = 0.0
nav_per_unit = cash_balance / nav_units
market_stock_balance = 0.0

qty = 0.0

puts '============================================================================='
puts "Starting Cash Balance: #{cash_balance}"
puts "Starting Stock Balance: #{stock_balance}"
puts "Starting Net Asset Value Units: #{nav_units}"
puts "Starting NAV per Unit: #{nav_per_unit}"
puts '============================================================================='

trades_array.each_with_index do |trade, idx|
	# this is a buy or sell
	if trade[:qty] != nil
		book_value = trade[:qty] * trade[:price] * -1
		cash_balance += book_value
		stock_balance += (book_value * -1)
		puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Price: #{trade[:price]} || Qty: #{trade[:qty]} || Book Value: #{book_value} || Cash Balance: #{cash_balance} || Stock Balance: #{stock_balance}"
		puts "#{trade[:date]} :: #{open_positions}"
	#this is market
	else
		#market_value = trade[:price] #broken
		#market_stock_balance += (market_value * -1)
		puts "[#{idx+1}] || #{trade[:date]} || [#{trade[:desc]}] || [#{trade[:ticker]}] || Price: #{trade[:price]} || Market Value: "
	end
end

puts '============================================================================='
puts 'Positions:'
open_positions.each do |op|
	if op[:qty] > 0
		puts "Ticker: #{op[:ticker]} || Book Price: #{op[:price]} || Qty: #{op[:qty]}"
	else
		puts "Ticker: #{op[:ticker]} || Book Price: #{op[:price]} || Qty: #{op[:qty]} - [CLOSED]" 
	end
end