#!/usr/bin/env ruby
require 'optparse'

# File where tasks will be stored
TASK_FILE = 'tasks.txt'

# Initialize an empty hash to store parsed options
options = {}

# 1. Define and parse command-line options using OptionParser
OptionParser.new do |opts|
  opts.banner = "Usage: cli.rb [options]"

  opts.on("-a", "--add TASK", "Add a new task") do |task|
    options[:add] = task
  end

  opts.on("-l", "--list", "List all tasks") do
    options[:list] = true
  end

  opts.on("-r", "--remove INDEX", "Remove a task by index") do |index|
    options[:remove] = index.to_i
  end

  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end.parse!

# Helper method to load existing tasks from file
def load_tasks
  if File.exist?(TASK_FILE)
    File.readlines(TASK_FILE).map(&:strip)
  else
    []
  end
end

# Helper method to save tasks back to file
def save_tasks(tasks)
  File.open(TASK_FILE, 'w') do |file|
    tasks.each { |task| file.puts(task) }
  end
end

# 2. Application Logic Execution based on the provided flags

# Handle ADD option
if options[:add]
  tasks = load_tasks
  tasks << options[:add]
  save_tasks(tasks)
  puts "Task '#{options[:add]}' added."

# Handle LIST option
elsif options[:list]
  tasks = load_tasks
  if tasks.empty?
    puts "No tasks found."
  else
    # Added the header required by the Holberton checker
    puts "Tasks:"
    tasks.each_with_index do |task, index|
      puts "#{index + 1}. #{task}"
    end
  end

# Handle REMOVE option
elsif options[:remove]
  tasks = load_tasks
  index_to_remove = options[:remove] - 1 # Convert 1-based index to 0-based

  if index_to_remove >= 0 && index_to_remove < tasks.length
    removed_task = tasks.delete_at(index_to_remove)
    save_tasks(tasks)
    puts "Task '#{removed_task}' removed."
  else
    puts "Error: Invalid task index."
  end
end
