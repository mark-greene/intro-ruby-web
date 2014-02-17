require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total cards
    arr = cards.map {|element| element[1]}

    total = 0
    arr.each do |rank|
      if rank == 'A'
        total += 11
      else
        total += rank.to_i == 0 ? 10 : rank.to_i
      end
    end

    arr.select { |element| element == 'A' }.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end
end

get '/' do
  if session[:player_name]
    redirect '/game'
  elsif
    redirect :new_player
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  suits = ['C', 'D', 'H', 'S']
  ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(ranks).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end
