require 'aws-sdk-ecs'

class Ecsnv
  attr_reader :profile, :cluster, :service_name, :ecs

  def initialize(options)
    @profile = options[:profile] || 'default'
    @cluster = options[:cluster]
    @service_name = options[:service_name]
  end

  def execute
    # TODO: handle API exceptions
    region = get_region_by_profile
    @ecs = Aws::ECS::Client.new(region: region, profile: profile)

    response = ecs.describe_services(cluster: cluster, services: [service_name])
    service = response.services.first
    task_definition_arn = service.task_definition

    # Retrieve the task definition
    task_definition_response = ecs.describe_task_definition(task_definition: task_definition_arn)
    task_definition = task_definition_response.task_definition

    # Retrieve the environment variables from the task definition
    env_vars = task_definition.container_definitions.first.environment

    env_vars.each do |var|
      puts "#{var.name}: #{var.value}"
    end
  end

  private
  def get_region_by_profile
    result = Aws.shared_config
    # Hack to access a private method :p
    config = result.instance_eval('@parsed_config')

    config.dig(profile, 'region')
  end
end
