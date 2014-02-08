# blackjack.rb
SUITS = ['Hearts', 'Spades', 'Diamonds', 'Clubs']
RANKS = [*2..10, 'Jack', 'Queen', 'King', 'Ace']
CARDS = []
  SUITS.product( RANKS ) { | suit, rank | CARDS << [rank, suit] }

  def print_cards cards
    cards.each do | rank, suit |
      puts "  #{rank} of #{suit}"
    end
  end

  def shuffle_cards cards
    cards.shuffle!
  end

  def cut_cards cards
    cards.rotate! cards.count / 2
  end

  def cards_contain cards, card
    cards.each do | rank, suit |
      if rank == card
        return true
      end
    end
    false
  end

  def print_card card
    rank, suit = card
    puts "#{rank} of #{suit}"
  end

  def draw_card cards
    cards.shift
  end

  def value_of_card card
    rank, suit = card

    case rank
    when 'Ace'
      11
    when 'King'
      10
    when 'Queen'
      10
    when 'Jack'
      10
    else
      rank.to_i
    end
  end

  def value_of_hand hand
    ace_count = 0
    value = 0

    hand.each do | card |
      rank, suit = card
      value += value_of_card card
      ace_count += 1 if rank == 'Ace'
    end

    while value > 21 && ace_count > 0
      value -= 10
      ace_count -= 1
    end
    value
  end

  def player_strategy hand, dealer_up_card
    strategy = :stand
    hand_value = value_of_hand hand
    card_value = value_of_card dealer_up_card

    if hand.count == 2 && cards_contain(hand, 'Ace')
      if hand_value >= 19
        strategy =  :stand
      elsif hand_value == 18 && [2, 7, 8].include?(card_value)
        strategy =  :stand
      else
        strategy = :hit
      end
    else
      if hand_value <= 11 || (hand_value == 12 && card_value.between?(2, 3))
        strategy =  :hit
      elsif hand_value >= 17 || card_value.between?(2, 6)
        strategy =  :stand
      elsif hand_value < (card_value + 10)
        strategy =  :hit
      end
    end
    strategy
  end

  def dealer_strategy hand
    v = value_of_hand hand
    v >= 17 && :stand || :hit
  end

  def results_of_hand hand
    v = value_of_hand hand
    case v
    when 21
      hand.count == 2 && :blackjack || 21
    when 2..20
      v
    when 0..1
      raise "error, illegal hand"
    else
      :bust
    end
  end

  def load_shoe number_of_decks
    shoe = []
    (1..number_of_decks).each { shoe += CARDS }
    shoe
  end


def game_simulation number_of_decks = 6, percent_reserved = 25.0

  cards = load_shoe number_of_decks

  number_of_reserve_cards = (cards.count.to_f * percent_reserved / 100).to_i
#  puts "Playing blackjack with #{number_of_decks} decks (#{cards.count} cards)" +
#      " and #{percent_reserved}% (#{number_of_reserve_cards} cards) in reserve"

  dealer_wins = 0
  player_wins = 0
  pushes = 0

  cards = shuffle_cards cards
  cards = cut_cards cards

  while cards.count > number_of_reserve_cards

    player = []
    dealer = []
    for i in 1..2
      card = draw_card cards
      player += [card]
      card = draw_card cards
      dealer += [card]
    end

    while player_strategy(player, dealer[1]) == :hit
      card = draw_card cards
      player += [card]
    end

    while dealer_strategy(dealer) == :hit
      card = draw_card cards
      dealer += [card]
    end

    player_result = results_of_hand(player)
    dealer_result = results_of_hand(dealer)
    if  (dealer_result == :blackjack && player_result != :blackjack) || player_result == :bust
  #    puts "Dealer wins with #{dealer_result}"
      dealer_wins += 1
    elsif player_result == :blackjack || dealer_result == :bust
  #    puts "Player wins with #{player_result}"
      player_wins += 1
    elsif dealer_result > player_result
  #    puts "Dealer wins with #{dealer_result}"
      dealer_wins += 1
    elsif player_result > dealer_result
  #    puts "Player wins with #{player_result}"
      player_wins += 1
    else
  #    puts "Push with #{dealer_result}"
      pushes += 1
    end
  # print_cards player
  # print_cards dealer
  end

  return dealer_wins, player_wins, pushes
end

def player_wants_a_hit? name, hand, upcard
  rank, suit = upcard
  puts "\n#{name} has #{value_of_hand(hand)}"
  print_cards hand

  if results_of_hand(hand)  == :blackjack
    puts "    *Blackjack*"
  elsif results_of_hand(hand) == :bust
    puts "    *Busted!"
  else
    puts "\nDo you want another card (Y/N)?"
    return gets.chomp.downcase == 'y'
  end
  false
end

def game_play name
  cards = load_shoe 2

  number_of_reserve_cards = (cards.count.to_f * 25 / 100).to_i
  puts "Playing Blackjack with a #{cards.count/52}-card deck"

  cards = shuffle_cards cards
  cards = cut_cards cards

  while cards.count > number_of_reserve_cards

    player = []
    dealer = []
    for i in 1..2
      card = draw_card cards
      player += [card]
      card = draw_card cards
      dealer += [card]
    end

    upcard_rank, upcard_suit = dealer[1]
    puts "\nDealer upcard is #{upcard_rank} of #{upcard_suit}"

    while player_wants_a_hit?(name, player, dealer[1])
      card = draw_card cards
      player += [card]
    end

    player_result = results_of_hand(player)

    if player_result != :bust
      while dealer_strategy(dealer) == :hit
        card = draw_card cards
        dealer += [card]
      end
    end

    puts "Dealer has #{value_of_hand(dealer)}"
    print_cards dealer

    dealer_result = results_of_hand(dealer)
    if  (dealer_result == :blackjack && player_result != :blackjack) || player_result == :bust
      puts "\nDealer wins with #{dealer_result}"
    elsif player_result == :blackjack || dealer_result == :bust
      puts "\n#{name} wins with #{player_result}"
    elsif dealer_result > player_result
      puts "\nDealer wins with #{dealer_result}"
    elsif player_result > dealer_result
      puts "\n#{name} wins with #{player_result}"
    else
      puts "\nPush with #{dealer_result}"
    end

    puts "\nPlay again #{name} (Y/N)"
    if gets.chomp.downcase == 'n'
      break
    end
  end
end

#main
require 'optparse'

options = {:name => 'Player', :play => false, :simulation => false}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: blackjack.rb [options]"
  opts.on("-h","--help","help") do
    puts opts
  end
  opts.on("-n", "--name Player", "Name") do |name|
    options[:name] = name
  end
  opts.on("-p", "--play", "Play Blackjack") do
    options[:play] = true
  end
  opts.on("-s", "--simulation", "Run Blackjack simulation") do
    options[:simulation] = true
  end
end

puts parser if ARGV.empty?

parser.parse!

game_play options[:name] if options[:play]

if options[:simulation]
  losses, wins, pushes = game_simulation
  puts "#{options[:name]} wins: #{wins}, pushes: #{pushes}\nDealer wins: #{losses}"
end
