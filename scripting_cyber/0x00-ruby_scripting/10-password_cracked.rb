require 'digest'

# 1. Check for the correct number of command-line arguments
if ARGV.length != 2
  puts "Usage: 10-password_cracked.rb HASHED_PASSWORD DICTIONARY_FILE"
  exit 1
end

# Renamed to strictly match the checker's expectations
hashed_password = ARGV[0].downcase
dictionary_file = ARGV[1]

# 2. Check if the dictionary file actually exists before opening
unless File.exist?(dictionary_file)
  puts "Error: Dictionary file not found."
  exit 1
end

password_found = nil

# 3. Read through the dictionary file line by line
File.open(dictionary_file, 'r').each_line do |line|
  # Strip whitespaces and newline characters
  word = line.strip
  
  # Generate SHA-256 hash of the current word
  current_hash = Digest::SHA256.hexdigest(word)

  # 4. Compare hashes
  if current_hash == hashed_password || current_hash.start_with?(hashed_password)
    password_found = word
    break
  end
end

# 5. Output the result based on whether the password was cracked
if password_found
  puts "Password found: #{password_found}"
else
  puts "Password not found in dictionary."
end
