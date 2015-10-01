require 'set'
require_relative 'player'
require 'byebug'

class Ghost
  attr_accessor :fragment, :losses
  attr_reader :players, :dictionary
  GAME_WORD = "GHOST"
  ALPHABET = ('a'..'z').to_a
  MAX_LOSS_COUNT = 5

  def initialize(players, dictionary_file_name)
    debugger
    @players = players.map {|player| Player.new(player)}
    @dictionary = Set.new(File.readlines(dictionary_file_name).map(&:chomp))
    @fragment = ""
    @losses = Hash.new { |hash, key| hash[key] = 0 }
  end

  def run
    until @players.count == 1
      play_round
      eliminate_player
    end
    puts "#{players.first.name} wins!"
  end

  private

  def valid_play?(input)
    ALPHABET.include?(input) && dict_includes?(input)
  end

  def dict_includes?(input)
    potential_frag = fragment + input
    dictionary.any? {|word| word.start_with?(potential_frag)}
  end

  def play_round
    until loss?
      puts "Current player is #{current_player.name}"
      input = take_turn(current_player)
      add_to_fragment(input)
      next_player!
      puts "The word is #{fragment}"
    end
    reset
    add_loss
    display_standings
  end

  def eliminate_player
    @players.delete(prev_player) if @losses[prev_player] == MAX_LOSS_COUNT
  end

  def display_standings
    puts "#{prev_player.name} lost"
    @players.each do |player|
      puts "#{player.name}: #{record(player)}"
      puts
    end
  end

  def reset
    @fragment = ""
  end

  def add_loss
    @losses[prev_player] += 1
  end

  def loss?
    @dictionary.include?(fragment)
  end

  def add_to_fragment(input)
    @fragment += input
  end

  def current_player
    @players.first
  end

  def prev_player
    @players.last
  end

  def next_player!
    @players.rotate!
  end

  def take_turn(player)
    until valid_play?(input = player.guess)
      player.alert_invalid_guess
    end
    input
  end

  def record(player)
    num_losses = losses[player]
    num_losses > 0 ? GAME_WORD[0..(num_losses - 1)] : nil
  end
end


if __FILE__ == $PROGRAM_NAME
  players = []
  count = 0
  loop do
    puts "Put a player name and press enter (Newline to end)"
    input = gets.chomp
    players << input if input != ''
    count += 1
    break if input == '' && count >= 2
  end
  file_name = "dictionary.txt"
  game = Ghost.new(players, file_name)
  game.run
end
