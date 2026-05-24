require 'net/http'
require 'uri'
require 'json'

# Performs an HTTP POST request sending JSON data to the specified URL
def post_request(url, body_params)
  # 1. Parse the string URL into a URI object
  uri = URI.parse(url)

  # 2. Create the Net::HTTP object and enable SSL if needed
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')

  # 3. Initialize the POST request
  request = Net::HTTP::Post.new(uri.path)
  
  # 4. Set the header to application/json so the server knows we are sending JSON
  request['Content-Type'] = 'application/json'
  
  # 5. Convert the hash to a real JSON string before sending (preserves integers)
  request.body = body_params.to_json

  # 6. Send the request and capture the response
  response = http.request(request)

  # 7. Print the response status code and message
  puts "Response status: #{response.code} #{response.message}"

  # 8. Parse and pretty print the response body (handling empty hash case)
  parsed_body = JSON.parse(response.body)
  puts "Response body:"
  
  if parsed_body.empty?
    puts "{}"
  else
    puts JSON.pretty_generate(parsed_body)
  end
end
