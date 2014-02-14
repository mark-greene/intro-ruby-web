# blackjack.rb

class Card
  RANKS = [*2..10, :Jack, :Queen, :King, :Ace]
  SUITS = [:Hearts, :Spades, :Diamonds, :Clubs]

  attr_reader   :rank, :suit

  def initialize rank, suit = :Clubs
    if RANKS.include?(rank) && SUITS.include?(suit)
      @rank = rank
      @suit = suit
    else
      raise ArgumentError, "invalid :rank or :suit"
    end
  end

  def == card
    rank == card.rank && suit == card.suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

end

class Deck
  protected
  attr_reader :cards, :number_of_reserve_cards
  public
  attr_reader :number_of_decks, :percent_reserved
  attr_reader :count

  def initialize number_of_decks = 1, percent_reserved = 20.0
    @number_of_decks = number_of_decks
    @percent_reserved = percent_reserved
    @cards = []
    Card::SUITS.product( Card::RANKS ) { | suit, rank | @cards << Card.new(rank, suit) }
    @cards = @cards * @number_of_decks
    @number_of_reserve_cards = (@cards.count.to_f * @percent_reserved / 100).to_i
  end

  def print
    puts "#{count}-card deck"
    self.cards.each do | card |
      puts "  #{card}"
    end
  end

  def shuffle
    self.cards.shuffle!
  end

  def cut
    self.cards.rotate! count / 2
  end

  def draw
    self.cards.shift
  end

  def count
    self.cards.count
  end

  def in_reserve?
    self.cards.count < self.number_of_reserve_cards
  end
end

class Hand
  protected
  attr_accessor :cards
  public
  attr_accessor :value

  def initialize card = nil
    if card.nil?
      @cards =  []
      @value = nil
    else
      @cards = [card]
      @value = hand_value
    end
  end

  def to_s
    s = ''
    self.cards.each { |card| s += "  #{card}\n"}
    s
  end

  def result
    case self.value
    when 21
      count == 2 && :blackjack || 21
    when 3..20
      self.value
    when 0..2
      raise "error, #{self.value} is an illegal hand"
    else
      :bust
    end
  end

  def add_card card
    self.cards += [card]
    self.value = hand_value
  end

  def count
    self.cards.count
  end

  def card position
    self.cards[position]
  end

  def card_value position
    case card(position).rank
    when :Ace
      11
    when :King
      10
    when :Queen
      10
    when :Jack
      10
    else
      card(position).rank
    end
  end

  def contains? rank
    self.cards.each do | card |
      if rank == card.rank
        return true
      end
    end
    false
  end

  def reset
    self.cards =  []
    self.value = nil
  end

  def hand_builder *ranks
    reset
    ranks.each { |rank| add_card( Card.new(rank)) }
    self
  end

  def hand_value
    ace_count = 0
    value_of_hand = 0

    self.cards.each_with_index do | card, index |
      value_of_hand += card_value index
      if card.rank == :Ace
        ace_count += 1
      end
    end

    while value_of_hand > 21 && ace_count > 0
      value_of_hand -= 10
      ace_count -= 1
    end
    value_of_hand
  end

  private :hand_value
end

class Dealer < Hand

  def strategy
    self.value >= 17 && :stand || :hit
  end

end

class Player < Hand

  def strategy dealer
    strategy = :stand

    if self.count == 2 && self.contains?(:Ace)
      if self.value >= 19
        strategy =  :stand
      elsif self.value == 18 && [2, 7, 8].include?(dealer.card_value(1))
        strategy =  :stand
      else
        strategy = :hit
      end
    else
      if self.value <= 11 || (self.value == 12 && dealer.card_value(1).between?(2, 3))
        strategy =  :hit
      elsif self.value >= 17 || dealer.card_value(1).between?(2, 6)
        strategy =  :stand
      elsif self.value < (dealer.card_value(1) + 10)
        strategy =  :hit
      end
    end
    strategy
  end

end

class Blackjack
  protected
  attr_reader :number_of_decks, :percent_reserved
  attr_reader :cards
  public
  attr_accessor   :total, :wins, :pushes, :losses

  def initialize number_of_decks = 6, percent_reserved = 25.0
    @number_of_decks = number_of_decks
    @percent_reserved = percent_reserved
    @cards = Deck.new @number_of_decks, @percent_reserved

    @total = 0
    @wins = 0
    @pushes = 0
    @losses = 0
  end

  def simulation
    get_cards_ready_to_deal

    while !self.cards.in_reserve? do
      player, dealer = deal_initial_hands

      while player.strategy(dealer) == :hit do
        player.add_card(self.cards.draw)
      end

      while dealer.strategy == :hit do
        dealer.add_card(self.cards.draw)
      end

      check_hand_results player, dealer
    end
  end

  def get_cards_ready_to_deal
    self.cards.shuffle
    self.cards.cut
  end

  def deal_initial_hands
    player = Player.new
    dealer = Dealer.new
    player.add_card(self.cards.draw)
    dealer.add_card(self.cards.draw)
    player.add_card(self.cards.draw)
    dealer.add_card(self.cards.draw)
    return player, dealer
  end

  def check_hand_results player, dealer
    if  (dealer.result == :blackjack && player.result != :blackjack) \
        || (dealer.result == :blackjack && player.result != 21) \
        || player.result == :bust
      results = "Dealer wins with #{dealer.result}"
      self.losses += 1
    elsif player.result == :blackjack \
        || dealer.result == :bust
      results = "Player wins with #{player.result}"
      self.wins += 1
    elsif dealer.result > player.result
      results = "Dealer wins with #{dealer.result}"
      self.losses += 1
    elsif player.result > dealer.result
      results = "Player wins with #{player.result}"
      self.wins += 1
    else
      results = "Push"
      self.pushes += 1
    end
    self.total += 1
    results
  end

  def play name = 'Player'
    get_cards_ready_to_deal

    while !self.cards.in_reserve? do
      player, dealer = deal_initial_hands

      puts "\nDealer upcard is - #{dealer.card(1)} -"

      while player_wants_a_card?(player, dealer, name) do
        player.add_card(self.cards.draw)
      end

      if player.result != :bust
        while dealer.strategy == :hit do
          dealer.add_card(self.cards.draw)
        end
      end

      puts "\nDealer has #{dealer.value}"
      puts "#{dealer}"

      puts "\n*** #{check_hand_results player, dealer}"

      puts "\nPlay again #{name} (Y*/N)"
      if gets.chomp.downcase == 'n'
        break
      end
    end
  end

  def player_wants_a_card? player, dealer, name = 'Player'
    puts "\n#{name} has #{player.value}"
    puts "#{player}"

    if player.result == :blackjack
      puts "    *Blackjack*"
    elsif player.result == :bust
      puts "    *Busted!"
    else
      puts "\nDo you want another card (Y/N*)?"
      return gets.chomp.downcase == 'y'
    end
    false
  end

end

#main
require 'optparse'

options = {:name => 'Player', :play => false, :simulation => false}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: blackjack.rb [options]"
  opts.separator ""
  opts.on("-h","--help","Displays usage options") do
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
  opts.on("-f", "--format", "rspec passthrough/hack") do
  end
end

puts parser if ARGV.empty?

parser.parse!

if options[:simulation]
  game = Blackjack.new
  game.simulation
  puts "#{options[:name]} wins: #{game.wins}, pushes: #{game.pushes}\nDealer wins: #{game.losses}"
  puts "\n    In #{game.total} games, Player wins #{"%0.2f" % ((game.wins / game.total.to_f) * 100)}%"
  puts "       Player doesn't loose #{"%0.2f" %(((game.wins + game.pushes) / game.total.to_f) * 100)}%"
end

if options[:play]
  game = Blackjack.new
  game.play options[:name]
  puts "#{options[:name]} wins: #{game.wins}, pushes: #{game.pushes}\nDealer wins: #{game.losses}"
  puts "\n    In #{game.total} games, Player wins #{"%0.2f" % ((game.wins / game.total.to_f) * 100)}%"
  puts "       Player doesn't loose #{"%0.2f" %(((game.wins + game.pushes) / game.total.to_f) * 100)}%"
end
