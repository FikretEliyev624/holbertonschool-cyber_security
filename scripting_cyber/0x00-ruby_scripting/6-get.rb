require 'net/http'
require 'uri'
require 'json'

# Performs an HTTP GET request to the specified URL and prints status and parsed JSON body
def get_request(url)
  # 1. Parse the string URL into a URI object
  uri = URI.parse(url)

  # 2. Send the HTTP GET request
  response = Net::HTTP.get_response(uri)

  # 3. Print the response status code and message (e.g., "200 OK")
  puts "Response status: #{response.code} #{response.message}"

  # 4. Parse the body as JSON and regenerate it with pretty formatting
  parsed_body = JSON.parse(response.body)
  puts "Response body:"
  puts JSON.pretty_generate(parsed_body)
end
