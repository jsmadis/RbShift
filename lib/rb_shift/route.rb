# frozen_string_literal: true

require_relative 'openshift_kind'

module RbShift
  # Representation of OpenShift route
  class Route < OpenshiftKind
    # Constructs route address
    # @return [String] address
    def address
      host        = obj.dig(:spec, :host)
      termination = obj.dig(:spec, :tls, :termination)
      protocol    = termination ? 'https' : 'http'
      "#{protocol}://#{host.chomp '/'}"
    end

    def change_service(name, port)
      @obj[:spec][:to][:name] = name
      @obj[:spec][:port][:targetPort] = port
    end
  end
end
