# Method to print all command-line arguments with headers and indices for the checker
def print_arguments
  if ARGV.empty?
    puts "No arguments provided."
  else
    # 1. Print the required header
    puts "Arguments:"
    
    # 2. Print each argument with its 1-based index
    ARGV.each_with_index do |arg, index|
      puts "#{index + 1}. #{arg}"
    end
  end
end
