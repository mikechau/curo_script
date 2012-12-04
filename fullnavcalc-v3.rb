# Full Nav Calc V.0.0.3
require 'date'

transactions = [
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 5.00, :acc_for => 'no'},
                {:date => '2011-04-17', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 5.00, :acc_for => 'no'},
                {:date => '2011-04-17', :action => "BUY", :ticker => "AAPL", :price => 10.00, :qty => 5.00, :acc_for => 'no' }
                {:date => '2011-04-19', :action => "SELL", :ticker => "AAPL", :price => 10.00, :qty => 20.00, :acc_for => 'no'},
                {:date => '2011-04-22', :action => "SELL", :ticker => "AAPL", :price => 15.00, :qty => 5.00, :acc_for => 'no'},
                {:date => '2011-04-22', :action => "SELL", :ticker => "AAPL", :price => 15.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-05-01', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 55.00, :acc_for => 'no'},
                {:date => '2011-05-02', :action => "BUY", :ticker => "AAPL", :price => 13.00, :qty => 55.00, :acc_for => 'no'},
                {:date => '2011-05-04', :action => "SELL", :ticker => "AAPL", :price => 13.00, :qty => 100.00, :acc_for => 'no'},
                {:date => '2011-05-04', :action => "SELL", :ticker => "AAPL", :price => 13.00, :qty => 10.00, :acc_for => 'no'},
                {:date => '2011-05-19', :action => "BUY", :ticker => "AAPL", :price => 100.00, :qty => 5000.00, :acc_for => 'no'},
                {:date => '2011-05-20', :action => "BUY", :ticker => "AAPL", :price => 101.00, :qty => 500.00, :acc_for => 'no'},
                {:date => '2011-05-25', :action => "SELL", :ticker => "AAPL", :price => 100.00, :qty => 500.00, :acc_for => 'no'}
               ]

eod_prices = [
              {:date => '2011-04-15', :ticker => 'AAPL', :eod_price => 9.00},
              {:date => '2011-04-16', :ticker => 'AAPL', :eod_price => 10.00},
              {:date => '2011-04-17', :ticker => 'AAPL', :eod_price => 11.00},
              {:date =>'2011-04-18', :ticker => 'AAPL', :eod_price => 12.00},
              {:date => '2011-04-19', :ticker => 'AAPL', :eod_price => 11.00},
              {:date => '2011-04-20', :ticker => 'AAPL', :eod_price => 13.00},
              {:date => '2011-04-21', :ticker => 'AAPL', :eod_price => 12.00},
              {:date => '2011-04-22', :ticker => 'AAPL', :eod_price => 14.00},
              {:date => '2011-05-01', :ticker => 'AAPL', :eod_price => 17.00},
              {:date => '2011-05-02', :ticker => 'AAPL', :eod_price => 19.00},
              {:date => '2011-05-03', :ticker => 'AAPL', :eod_price => 22.00},
              {:date => '2011-05-21', :ticker => 'AAPL', :eod_price => 31.00},
              {:date => '2011-06-04', :ticker => 'AAPL', :eod_price => 10.00},
              {:date => '2011-06-09', :ticker => 'AAPL', :eod_price => 10.00}
             ]

###### EMPTY ARRAYS ###### 

open_positions = []

market_status_array = []
trades_array = []

###### Taking arrays to create a main array to work with ###### 

#loop through the transactions array
transactions.each_with_index do |trade,idx|

  # shovel the transactions hash without :acc_for hash into trades_array
  trades_array << {:date => trade[:date], :desc => trade[:action], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty]}

############# BUY CHECK
  if trade[:action] == 'BUY'

  ###############################################
    #check if Buy exists in open_positions array, if not add to array
    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:date] == trade[:date] && o[:qty] > 0}
      matching_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price]}
      last_index = (matching_positions.count) - 1
      matching_positions[last_index][:qty] += trade[:qty]
      trade[:acc_for] = 'yes'
    else
      open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => trade[:price], :qty => trade[:qty]}
        if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && Date.parse(o[:date]) < Date.parse(trade[:date])}
          matching_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && Date.parse(o[:date]) < Date.parse(trade[:date])}
          last_index = (matching_positions.count) - 1
          add_previous_qty = matching_positions[last_index][:qty]
          last_position = (open_positions.count) - 1
          open_positions[last_position][:qty] += add_previous_qty
        end
    end
  ###############################################

  ###############################################
    #check if the ticker exists in the market data table
    if eod_prices.any? {|t| t[:ticker] == trade[:ticker]}

      #finds the first sell date that has not been marked
      if transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}
        stop_date = transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}

        #set end_day to the SELL transaction that has not been marked by :acc_for
        end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date]) && Date.parse(t[:date]) < Date.parse(stop_date[:date])}

        #runs through the array pulled from .select and shovels into the market_status_array
        end_day.each do |history|
          market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price]}
        end

        # marks the SELL transaction :acc_for to 'yes'
        transactions.find {|t| t[:ticker] == trade[:ticker] && t[:action] == 'SELL' && t[:acc_for] == 'no'}[:acc_for] = 'yes'

      elsif transactions.any? {|t| t[:ticker] == trade[:ticker] && t[:action] == 'BUY'} && trade[:acc_for] == 'no'
        end_day = eod_prices.select {|t| t[:ticker] == trade[:ticker] && Date.parse(t[:date]) >= Date.parse(trade[:date])}
        
        end_day.each do |history|
          market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price]}
        end

      else
        puts "ERROR: #{trade}"
      end
    end
  ###############################################

############# SELL CHECK    
  elsif trade[:action] == 'SELL'

  ###############################################

  most_recent = open_positions.select {|o| o[:ticker] == trade[:ticker]}
  most_recent = most_recent.reverse
  most_recent = most_recent.uniq! {|o| o[:price]}
  most_recent = most_recent.reverse

  puts "Most recent: #{most_recent}"

    if most_recent.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:date] == trade[:date]}
      op = most_recent.find {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:date] == trade[:date]}
      difference = op[:qty] - trade[:qty]
      open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => difference}

    elsif most_recent.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && Date.parse(o[:date]) < Date.parse(trade[:date])}
      matching_positions = most_recent.select {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0 && Date.parse(o[:date]) < Date.parse(trade[:date])}
      puts matching_positions
      last_index = (matching_positions.count) - 1
      previous_qty = matching_positions[last_index -1][:qty]
      new_qty = previous_qty - trade[:qty]

      open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => matching_positions[last_index][:price], :qty => new_qty, :debug => '1'}

    elsif most_recent.any? {|o| o[:ticker] == trade[:ticker]}
      op_select = most_recent.select {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0}
      op_select = op_select.reverse
      op_select = op_select.uniq! {|o| o[:price]}
      if op_select == nil
        op_select = most_recent.select {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0}
      else
        op_select = op_select.reverse
      end      

      qty_sold = trade[:qty]
      puts qty_sold
      op_select.each do |op|
        if qty_sold > 0

          if qty_sold >= op[:qty]
            remainder = qty_sold - op[:qty]
            op_decrease = qty_sold - remainder
            qty_subtracted = op[:qty] - op_decrease
            open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted, :test => '1'}
            qty_sold = remainder
          else
            qty_subtracted = op[:qty] - qty_sold
            open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted, :test => '2'}
          end
        end
      end
    else
      puts "ERROR: #{trade}"
    end
  ###############################################
  else
    puts 'ERROR: Action not BUY or SELL!'
  end
end

# puts '----OPEN POSITIONS---------'
# puts open_positions
# puts '----TRANSACTIONS---------'
# puts transactions


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