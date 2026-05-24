require 'open-uri'
require 'uri'
require 'fileutils'

# 1. Check if both URL and PATH arguments are provided
if ARGV.length != 2
  puts "Usage: 9-download_file.rb URL LOCAL_FILE_PATH"
  exit 1
end

url = ARGV[0]
local_path = ARGV[1]

begin
  puts "Downloading file from #{url}..."

  # 2. Ensure the destination directory exists
  dir = File.dirname(local_path)
  FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

  # 3. Open the URL and stream the content into the local file
  URI.open(url) do |remote_file|
    File.open(local_path, 'wb') do |local_file|
      local_file.write(remote_file.read)
    end
  end

  puts "File downloaded and saved to #{local_path}."

rescue StandardError => e
  puts "Error downloading file: #{e.message}"
  exit 1
end
