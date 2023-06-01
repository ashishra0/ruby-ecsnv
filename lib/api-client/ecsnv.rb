require 'aws-sdk-ecs'
require 'pry'

class Ecsnv
  attr_reader :profile, :cluster, :service_name, :ecs, :region, :ecs_services

  def initialize(options)
    @profile = options[:profile] || 'default'
    @cluster = options[:cluster]
    @service_name = options[:service_name]
    @region = get_region_by_profile
    @ecs = Aws::ECS::Client.new(region: region, profile: profile)
  end

  def print_to_console
    env_vars = get_env_vars
    env_vars.each do |env|
      puts "#{env.name}=#{env.value}"
    end
  end

  def write_to_file(filename)
    env_vars = get_env_vars
    File.open(filename, 'w') do |file|
      file.write(
        env_vars.map { |env| "#{env.name}=#{env.value}" }.join("\n")
      )
    end
  end

  private
  def get_region_by_profile
    result = Aws.shared_config
    # Hack to access a private method :p
    config = result.instance_eval('@parsed_config')

    config.dig(profile, 'region')
  end

  def get_ecs_services_list
    ecs.describe_services(cluster: cluster, services: [service_name])
    # TODO handle API exceptions
  end

  def get_task_definition_from_service
    response = get_ecs_services_list
    service = response.services.first
    task_definition_arn = service.task_definition
    task_definition_response = ecs.describe_task_definition(task_definition: service.task_definition)
    task_definition = task_definition_response.task_definition
  end

  def get_env_vars
    task_definition = get_task_definition_from_service

    task_definition.container_definitions.first.environment
  end
end
