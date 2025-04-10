color_options = {
  orange: "\u{1F7E0}", # 🟠
  yellow: "\u{1F7E1}", # 🟡
  green: "\u{1F7E2}",  # 🟢
  blue: "\u{1F7E3}",   # 🔵
  black: "\u{26AB}",   # ⚫
  red: "\u{1F534}"     # 🔴
}
passkey = Array.new(4) { color_options.values.sample }

puts(passkey.inspect)

def valid_guess?(guess, valid_colors)
  guess.is_a?(Array) && guess.size == 4 && guess.all? { |color| valid_colors.include?(color.to_sym) }
end

puts "Make your first guess (enter 4 colors separated by commas, e.g., orange,blue,red,green):"
loop do
  guess = gets.chomp.split(",").map(&:strip)
  if valid_guess?(guess, color_options.keys)
    puts "Your guess: #{guess.map { |color| color_options[color.to_sym] }.join(' ')}"
    break
  else
    puts "Invalid input. Please enter 4 valid colors separated by commas (e.g., orange,blue,red,green):"
  end
end