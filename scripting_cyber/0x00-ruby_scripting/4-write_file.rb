require 'json'

# Merges the JSON array from file1 into file2
def merge_json_files(file1_path, file2_path)
  # 1. Read and parse the content of the first JSON file
  file1_content = File.read(file1_path)
  data1 = JSON.parse(file1_content)

  # 2. Read and parse the content of the second JSON file
  file2_content = File.read(file2_path)
  data2 = JSON.parse(file2_content)

  # 3. Combine both arrays (data1 objects will be appended/merged into data2)
  merged_data = data2 + data1

  # 4. Write the combined data back to file2, formatting it as a clean JSON string
  File.open(file2_path, 'w') do |f|
    f.write(JSON.pretty_generate(merged_data))
  end

  # 5. Print the confirmation required by the Holberton checker
  puts "Merged JSON written to #{file2_path}"
end
