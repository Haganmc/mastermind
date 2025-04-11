class Mastermind
  attr_accessor :passkey, :guess, :feedback, :history
  attr_reader :COLOR_OPTIONS, :CORRECT_PLACE, :CORRECT_COLOR, :INCORRECT_GUESS

  def initialize(passkey = nil)
    @COLOR_OPTIONS = {
      orange: "\u{1F7E0}", # 🟠
      yellow: "\u{1F7E1}", # 🟡
      green: "\u{1F7E2}",  # 🟢
      blue: "\u{1F7E3}",   # 🔵
      black: "\u{26AB}",   # ⚫
      red: "\u{1F534}",    # 🔴
    }
    @passkey = passkey || generate_passkey
    @guess = []
    @feedback = []
    @history = [] # Store history of guesses and feedback
  end

  CORRECT_PLACE = "\u{1F534}" # 🔴 (Red for correct guesses in the correct place)
  CORRECT_COLOR = "\u{26AA}" # ⚪ (White for correct guesses in the wrong place)
  INCORRECT_GUESS = "\u{26AB}" # ⚫ (Black for incorrect guesses)

  def get_guess
    puts "Make your guess (enter 4 colors separated by commas, options: red, black, orange, blue, green, yellow):"
    loop do
      @guess = gets.chomp.split(",").map(&:strip)
      if valid_guess?(@guess, @COLOR_OPTIONS.keys)
        puts "Your guess: #{@guess.map { |color| @COLOR_OPTIONS[color.to_sym] }.join(' ')}"
        compare_guess
        break
      else
        puts "Invalid input. Please enter 4 valid colors separated by commas (e.g., orange,blue,red,green, yellow):"
      end
    end
  end

  def valid_guess?(guess, valid_colors)
    guess.is_a?(Array) && guess.size == 4 && guess.all? { |color| valid_colors.include?(color.to_sym) }
  end

  def compare_guess
    @feedback.clear

    # Create a copy of the passkey to track unmatched colors
    unmatched_passkey = @passkey.dup
    unmatched_guess = []

    # First pass: Check for correct guesses (right color and position)
    @guess.each_with_index do |color, index|
      if color.to_sym == unmatched_passkey[index]
        @feedback << CORRECT_PLACE
        unmatched_passkey[index] = nil # Mark as matched
      else
        unmatched_guess << color.to_sym # Track unmatched guesses
      end
    end

    # Second pass: Check for correct guesses (right color, wrong position)
    unmatched_guess.each do |color|
      if unmatched_passkey.include?(color)
        @feedback << CORRECT_COLOR
        unmatched_passkey[unmatched_passkey.index(color)] = nil # Mark as matched
      end
    end

    # Fill remaining feedback slots with incorrect guesses
    while @feedback.size < 4
      @feedback << INCORRECT_GUESS
    end

    # Add the current guess and feedback to the history
    @history << { guess: @guess.dup, feedback: @feedback.dup }
  end

  def play
    puts "Welcome to Mastermind!"
    puts "You have 10 attempts to guess the passkey."
    puts "The passkey consists of 4 colors chosen from: #{@COLOR_OPTIONS.keys.join(', ')}"
    puts "Correct guesses in the correct place are represented by #{CORRECT_PLACE} (red)."
    puts "Correct guesses in the wrong place are represented by #{CORRECT_COLOR} (white)."
    puts "Incorrect guesses are represented by #{INCORRECT_GUESS} (black)."

    10.times do |attempt|
      puts "\nAttempt #{attempt + 1} of 10:"
      get_guess
      display_history # Show the history of guesses
      if @feedback.count(CORRECT_PLACE) == 4
        puts "Congratulations! You've guessed the passkey: #{@passkey.map { |color| @COLOR_OPTIONS[color] }.join(' ')}"
        return
      else
        display_feedback
        puts "Try again!"
      end
    end

    puts "Game over! The passkey was: #{@passkey.map { |color| @COLOR_OPTIONS[color] }.join(' ')}"
  end

  private

  def generate_passkey
    Array.new(4) { @COLOR_OPTIONS.keys.sample }
  end

  def display_feedback
    # Ensure feedback is ordered: colored feedback first, then black
    ordered_feedback = @feedback.sort_by { |f| f == INCORRECT_GUESS ? 1 : 0 }

    # Pad the feedback to ensure it always has 4 items
    feedback_grid = ordered_feedback + Array.new(4 - ordered_feedback.size, INCORRECT_GUESS)

    # Display the feedback in a 2x2 grid
    puts "Feedback:"
    puts "#{feedback_grid[0]} #{feedback_grid[1]}"
    puts "#{feedback_grid[2]} #{feedback_grid[3]}"
  end

  def display_history
    puts "\nHistory of guesses:"
    @history.each_with_index do |entry, index|
      guess_display = entry[:guess].map { |color| @COLOR_OPTIONS[color.to_sym] }.join(' ')
      feedback_display = entry[:feedback].join(' ')
      puts "Attempt #{index + 1}: Guess: #{guess_display} | Feedback: #{feedback_display}"
    end
  end
end

# Start the game
game = Mastermind.new
game.play
