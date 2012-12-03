# Full Nav Calc V.0.0.4
require 'date'

transactions = [
                {:date => '2011-04-16', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-18', :action => "BUY", :ticker => "AAPL", :price => 12.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-19', :action => "SELL", :ticker => "AAPL", :price => 11.00, :qty => 20.00, :acc_for => 'no'},
                {:date => '2011-04-20', :action => "BUY", :ticker => "AAPL", :price => 11.00, :qty => 15.00, :acc_for => 'no'},
                {:date => '2011-04-20', :action => "BUY", :ticker => "GOOG", :price => 12.00, :qty => 5.00, :acc_for => 'no'}
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
              {:date => '2011-06-09', :ticker => 'AAPL', :eod_price => 10.00},
              {:date => '2011-06-09', :ticker => 'GOOG', :eod_price => 10.00}
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
    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:qty] > 0 && o[:date] == trade[:date] && o[:mark] == nil} 
      matching_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == trade[:price] && o[:mark] == nil}
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

    unique_prices = transactions.select {|o| o[:ticker] == trade[:ticker]}.uniq! {|t| t[:price]}
    puts unique_prices
    if unique_prices != nil
      unique_prices.each_with_index do |uq, idx|
        check_positions = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:price] == uq[:price]}
        check_pos_count = check_positions.count - 1
        check_positions.each_with_index do |pos, idx|
          if idx < check_pos_count
            pos[:mark] = 'yes'
          end
        end
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
          market_status_array << {:date => history[:date], :desc => 'MRKT', :ticker => history[:ticker], :price => history[:eod_price], :index => trade[:date]}
        end

      else
        puts "[EOD] - ERROR: #{trade}"
      end

    end
  ###############################################

############# SELL CHECK    
  elsif trade[:action] == 'SELL'

  ###############################################

    if open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:mark] != 'yes'}
      ops = open_positions.find {|o| o[:ticker] == trade[:ticker] && o[:qty] >= trade[:qty] && o[:mark] != 'yes'}
      difference = ops[:qty] - trade[:qty]
      open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => ops[:price], :qty => difference, :wtf => 'yo'}
    
    elsif open_positions.any? {|o| o[:ticker] == trade[:ticker] && o[:qty] < trade[:qty] && o[:mark] != 'yes'}
      ops = open_positions.select {|o| o[:ticker] == trade[:ticker] && o[:qty] > 0 && o[:mark] != 'yes'}
      qty_sold = trade[:qty]
      ops.each do |op|
        if qty_sold > 0 && qty_sold >= op[:qty]
          remainder = qty_sold - op[:qty]
          op_decrease = qty_sold - remainder
          qty_subtracted = op[:qty] - op_decrease
          open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted}
          qty_sold = remainder
        elsif qty_sold > 0 && qty_sold < op[:qty]
          qty_subtracted = op[:qty] - qty_sold
          open_positions << {:date => trade[:date], :ticker => trade[:ticker], :price => op[:price], :qty => qty_subtracted}
        else
          puts "Error: Check ops.each. #{trade}"
        end 
      end

    else
      puts "Error: Check Sell conditional. #{trade}"
    end

  ###############################################

  else
    puts '[BUY/SELL] - ERROR: Action not BUY or SELL!'
  end

end

puts '----OPEN POSITIONS---------'
puts open_positions
puts '----TRANSACTIONS---------'
puts transactions
puts '----MARKET STATUS--------'

capture_tickers = transactions.uniq {|t| t[:ticker]}
market_log = []
capture_tickers.each do |ticker|
  symbol = ticker[:ticker]
  clean_market_status = market_status_array.select {|m| m[:ticker] == symbol}
  revised_market_array = clean_market_status.uniq {|c| c[:date]}

  revised_market_array.each do |market|
    market_log << market
  end
end

puts market_log