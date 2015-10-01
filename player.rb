class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def guess
    puts "#{name}: Enter a character"
    gets.chomp.downcase
  end

  def alert_invalid_guess
     puts "Not a valid entry"
  end
end
