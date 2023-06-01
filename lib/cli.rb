require 'optparse'
require 'colorize'
require 'tty-prompt'
require_relative 'api-client/ecsnv.rb'

options = {}

OptionParser.new do |parser|

  parser.banner = "This ruby implementation was inspired by the Go version: https://github.com/dineshgowda24/ecsnv
  \nDesription: CLI Application that lets you download your AWS ECS envs locally. The envs can be downloaded into a file.
  \nUsage: ecsnv -c <cluster> -s <service>".colorize(:color => :blue, :mode => :bold)

  options[:help] = parser.help

  parser.on("-c", "--cluster CLUSTER", "ECS Cluster name") do |cluster|
    options[:cluster] = cluster
  end

  parser.on("-s", "--service SERVICE", "ECS Service name, service to be paired with cluster") do |service|
    options[:service_name] = service
  end

  parser.on("-p", "--profile PROFILE", "AWS profile (overrides the default profile)") do |profile|
    options[:profile] = profile
  end
end.parse!

if options[:cluster].nil? && options[:service_name].nil?
  puts options[:help]
  exit 1
elsif options[:cluster].nil? || options[:service_name].nil?
  puts "Error: required flag(s) 'cluster' and 'service' should be paired together".colorize(:red)
  puts "Usage: ecsnv -c <cluster> -s <service>"
  exit 1
end

ecsnv = Ecsnv.new(options)

system("clear")
prompt = TTY::Prompt.new

selection = prompt.select("Choose one of the following".yellow, filter: true, per_page: 5) do |menu|
  menu.choice "Print to console"
  menu.choice "Write to file"
  menu.choice "Exit"
end

case selection
when "Print to console"
  ecsnv.print_to_console
when "Write to file"
  filename = prompt.ask("Enter filename to export the envs", default: "envs.txt")
  ecsnv.write_to_file(filename)
when "Display clusters"
  ecsnv.display_clusters
when "Exit"
  system("exit")
end
