require 'optparse'
require 'colorize'
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

  parser.on("-p", "--profile PROFILE", "AWS profile(overrides the default profile)") do |profile|
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

Ecsnv.new(options).execute