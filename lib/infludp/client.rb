module Infludp
  class Client
    attr_accessor :host, :port

    def initialize(args)
      @host = args[:host]
      @port = args[:port]
    end

    def socket
      Thread.current[:infludp_socket] ||= UDPSocket.new
    end

    def send(name, tags, fields)
      socket.send(
          build_metric(name, tags, fields),
          0,
          host,
          port
      )
    end

    def build_metric(name, tags, fields)
      "#{name},#{to_tag_line(tags)} #{to_field_line(fields)}"
    end

    def to_field_line(hash)
      hash.map do |key, value|
        if value.is_a?(String)
          "#{key}=\"#{value}\""
        else
          "#{key}=#{value}"
        end
      end.join(',')
    end

    def to_tag_line(hash)
      hash.map do |key, value|
        str_value = value.to_s
        if str_value.match?(/\s/)
          "#{key}=#{str_value.gsub(/ /, '\ ')}"
        else
          "#{key}=#{str_value}"
        end
      end.join(',')
    end
  end
end
