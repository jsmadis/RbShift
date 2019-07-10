# frozen_string_literal: true

require_relative 'openshift_kind'
require_relative 'route'

module RbShift
  # Representation of OpenShift service
  class Service < OpenshiftKind
    def routes(update = false)
      @_routes = load_routes if update || @_routes.nil?
      @_routes
    end

    def filter_routes_by_labels(update = false, labels: {})
      routes = routes(update)
      routes.select do |_, value|
        (labels.to_a - value.metadata.labels.to_a).empty?
      end

    end

    def create_route(name, hostname, termination = 'edge', **opts)
      log.info "Creating route #{name} #{hostname} for service #{self.name}"
      if termination
        execute "create route #{termination} #{name}",
                hostname: hostname,
                service:  self.name,
                **opts
      else
        execute "expose service #{@name}", hostname: hostname, name: name, **opts
      end
      routes true if @_routes
    end

    def ports
      @obj[:spec][:ports].each_with_object({}) { |v, h| h[v[:name].to_sym] = v }
    end

    private

    def load_routes
      items = parent.client
                .get('routes', namespace: parent.name)
                .select { |item| item[:spec][:to][:name] == name }

      items.each_with_object({}) do |item, hash|
        resource            = Route.new(self, item)
        hash[resource.name] = resource
      end
    end
  end
end
