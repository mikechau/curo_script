require 'date'

transactions = [
								{:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 10.00, :qty => 5.00, :acc_for => 'no' },
								{:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 10.00, :qty => 5.00, :acc_for => 'no' },
								{:date => '2011-04-20', :action => "SELL", :ticker => "AAPL", :price => 15.00, :qty => 5.00, :acc_for => 'no' },
								{:date => '2011-04-20', :action => "BUY", :ticker => "AAPL", :price => 15.00, :qty => 5.00, :acc_for => 'no' },
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

open_positions = []

# postions_sample = [
# 									 {:ticker => 'AAPL', :price => 10.00, :qty => 5.00}
# 									]



nav_units = 1000.00
balance = 2000.00
nav_per_unit = balance / nav_units

# puts transactions.any? {|t| t[:date] == '2011-04-16'}
# puts transactions.select {|t| t[:ticker] == 'AAPL' && t[:action] == 'BUY' && t[:date] == '2011-04-16'}
# puts transactions.select {|t| t[:ticker] == 'AAPL' }
# puts '====='



transactions.each_with_index do |trade, index|

	if trade[:action] == "BUY"
		puts "[BUY] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"

		#check if Buy exists in open_positions array, if not add to array
		if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price]}
			match_position = open_positions.find {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price]}
			puts open_positions.index(match_position)
			
			trade[:acc_for] = 'yes'		
		else
			open_positions << {:ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty]}
		end

		#check if the ticker exists in the market data table
		if eod_prices.any? {|t| t[:ticker] == trade[:ticker]}

			#finds the first sell date that has not been marked
			if transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == "SELL" && t[:acc_for] == 'no'}
				stop_date = transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == "SELL" && t[:acc_for] == 'no'}

				#set end_day to the SELL transaction that has not been marked by :acc_for
				end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date]) && Date.parse(t[:date]) < Date.parse(stop_date[:date])}
				end_day_count = end_day.count

				#runs through the array pulled from .select and prints the market prices
				# eventually shovel into new array to organize w/ other stocks
				end_day.each_with_index do |history, index|
					puts "[MRKT] => #{history[:date]} || TICKER: #{history[:ticker]} || PRICE: #{history[:eod_price]}"
				end

				# marks the SELL transaction :acc_for to 'yes'
				transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == "SELL" && t[:acc_for] == 'no'}[:acc_for] = 'yes'
		
			# there are no 'SELL' actions, continue displaying market prices
			elsif transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == "BUY"} && trade[:acc_for] == 'no'
				end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date])}
				end_day_count = end_day.count
				end_day.each_with_index do |history, index|
					puts "[MRKT] => #{history[:date]} || TICKER: #{history[:ticker]} || PRICE: #{history[:eod_price]}"
				end

			else
				puts 'Error: Something went wrong!'
			end

		end

	elsif trade[:action] == "SELL"
		puts "[SELL] => #{trade[:date]} || TICKER: #{trade[:ticker]} || PRICE: #{trade[:price]} || QTY: #{trade[:qty]}"
	else
		puts 'Error: Action is not "BUY" or "SELL" '
	end
end

puts 'Transactions:'
puts transactions
puts 'Open Positions:'
puts open_positions