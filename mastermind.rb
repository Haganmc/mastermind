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
    @passkey = passkey
    @guess = []
    @feedback = []
    @history = [] # Store history of guesses and feedback
  end

  CORRECT_PLACE = "\u{1F534}" # 🔴 (Red for correct guesses in the correct place)
  CORRECT_COLOR = "\u{26AA}" # ⚪ (White for correct guesses in the wrong place)
  INCORRECT_GUESS = "\u{26AB}" # ⚫ (Black for incorrect guesses)

  def play
    puts "Welcome to Mastermind!"
    puts "Would you like to be the creator of the secret code or the guesser?"
    puts "Enter 'creator' to create the code or 'guesser' to guess the code:"
    role = gets.chomp.downcase

    if role == 'creator'
      play_as_creator
    elsif role == 'guesser'
      play_as_guesser
    else
      puts "Invalid choice. Please enter 'creator' or 'guesser'."
      play
    end
  end

  def play_as_guesser
    @passkey = generate_passkey
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
    replay_game
  end

  def play_as_creator
    puts "Enter your secret code (4 colors separated by commas, options: red, black, orange, blue, green, yellow):"
    loop do
      @passkey = gets.chomp.split(",").map(&:strip).map(&:to_sym)
      if valid_guess?(@passkey, @COLOR_OPTIONS.keys)
        puts "Your secret code has been set!"
        break
      else
        puts "Invalid input. Please enter 4 valid colors separated by commas (e.g., orange,blue,red,green):"
      end
    end

    computer_guess
  end

  def computer_guess
    possible_colors = @COLOR_OPTIONS.keys
    possible_combinations = possible_colors.repeated_permutation(4).to_a # All possible combinations
    puts "The computer will now try to guess your passkey."
  
    10.times do |attempt|
      @guess = possible_combinations.sample # Pick a random guess from the remaining possibilities
      puts "\nComputer's Attempt #{attempt + 1}: #{@guess.map { |color| @COLOR_OPTIONS[color] }.join(' ')}"
      compare_guess
      display_feedback
  
      if @feedback.count(CORRECT_PLACE) == 4
        puts "The computer guessed your passkey: #{@guess.map { |color| @COLOR_OPTIONS[color] }.join(' ')}"
        return
      else
        # Narrow down possible combinations based on feedback
        possible_combinations.select! do |combination|
          feedback = []
          unmatched_passkey = @guess.dup
          unmatched_combination = []
  
          # First pass: Check for correct guesses (right color and position)
          combination.each_with_index do |color, index|
            if color == unmatched_passkey[index]
              feedback << CORRECT_PLACE
              unmatched_passkey[index] = nil
            else
              unmatched_combination << color
            end
          end
  
          # Second pass: Check for correct guesses (right color, wrong position)
          unmatched_combination.each do |color|
            if unmatched_passkey.include?(color)
              feedback << CORRECT_COLOR
              unmatched_passkey[unmatched_passkey.index(color)] = nil
            end
          end
  
          # Fill remaining feedback slots with incorrect guesses
          feedback += [INCORRECT_GUESS] * (4 - feedback.size)
  
          # Keep only combinations that would produce the same feedback
          feedback.sort == @feedback.sort
        end
      end
    end
  
    puts "The computer failed to guess your passkey: #{@passkey.map { |color| @COLOR_OPTIONS[color] }.join(' ')}"
    replay_game
  end

  def replay_game
    puts "Would you like to play again? (y/n)"
    answer = gets.chomp.downcase
    if answer == 'y'
      game = Mastermind.new
      game.play
    else
      puts "Thanks for playing!"
    end
  end

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

  private

  def generate_passkey
    Array.new(4) { @COLOR_OPTIONS.keys.sample }
  end
end

# Start the game
game = Mastermind.new
game.play