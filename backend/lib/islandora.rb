require 'net/http'
require 'securerandom'
require 'uri'

module Islandora
  class Client
    attr_reader :auth_method, :config, :token

    def initialize(config = {})
      # fake defaults (that should be overriden by config)
      @config = {
        base_url:  "https://sandbox.islandora.ca",
        rest_path: "/islandora/aspace/object",
        username:  "anonymous",
        password:  "nonsense",
        api_key:   nil,
        verbose:   true,
      }.merge(config)

      unless (@config[:username] and @config[:password]) or @config[:api_key]
        raise "Islandora configuration error: username AND password OR api_key required."
      end

      @auth_header = @config[:api_key] ? StringPreserveCase.new('X-Islandora-ASpace-ApiKey') : 'Cookie'
      @auth_method = @config[:api_key] ? :api_key : :login
      @token       = @auth_method == :api_key ? @config[:api_key] : nil
      @verbose     = @config[:verbose]
    end

    # check for islandora agent
    def agent_eligible?(agents)
      agent = agents.find { |a|
        a['role'] == "source" and a['_resolved']['display_name']['software_name'] == "Islandora"
      }
      debug "Islandora agent eligible: #{agent}" if agent
      agent
    end

    def debug(message)
      $stdout.puts "\n\n\n\n\n#{message}\n\n\n\n\n" if @verbose
    end

    def delete(uri)
      url      = "#{@config[:base_url]}#{@config[:rest_path]}/#{extract_pid(uri)}"
      request  = Request.new(
        "Delete", url, nil, {
          "Accept" => "application/json",
          @auth_header => @token
        }
      )
      response = request.perform
      response
    end

    def error(message)
      $stderr.puts "\n\n\n\n\n#{message}\n\n\n\n\n"
    end

    # check has associated ingest event and has matching location to uri
    # islandora.event_eligible? event, "http://sandbox.islandora.ca/islandora/object/islandora:root"
    def event_eligible?(events, uri)
      event = events.find { |evt|
        event   = evt['_resolved'];
        ext_doc = event['external_documents'][0];
        event['event_type'] == 'ingestion' and ext_doc and ext_doc['location'] == uri
      }
      debug "Islandora event eligible: #{event}" if event
      event
    end

    # get pid from url
    def extract_pid(uri)
      URI(uri).path.split('/').last
    end

    # get session / token from islandora via login form
    def login
      return @token if @token or @auth_method == :api_key
      request = Request.new("Post", "#{@config[:base_url]}/user/login")

      request.add_multipart_body ({
        name: @config[:username],
        pass: @config[:password],
        form_id: "user_login",
        op: "Log in",
      })

      response = request.perform
      @token   = response['Set-Cookie'].split(";")[0] if response and response['Set-Cookie']
      @token
    end

    # check object exists in islandora repository
    # islandora.object_exists? "http://sandbox.islandora.ca/islandora/object/islandora:root"
    def object_exists?(uri)
      url      = uri
      request  = Request.new("Get", url)
      response = request.perform
      exists   = (response and response.code.to_i == 200) ? true : false
      exists
    end

    # send object metadata to islandora
    # uri = http://sandbox.islandora.ca/islandora/object/islandora:root
    def update(uri, payload)
      url      = "#{@config[:base_url]}#{@config[:rest_path]}/#{extract_pid(uri)}"
      request  = Request.new(
        "Put", url, payload.to_s, {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Content-Length" => "nnnn",
          @auth_header => @token
        }
      )
      response = request.perform
      response
    end

    # check uri matches islandora base url
    # islandora.uri_eligible? "http://sandbox.islandora.ca/islandora/object/islandora:root"
    def uri_eligible?(uri)
      eligible = uri =~ /#{Regexp.escape(@config[:base_url])}/
      debug "Islandora uri eligible: #{uri}" if eligible
      eligible
    end

    class Request
      attr_accessor :body, :headers

      BOUNDARY = SecureRandom.hex

      def initialize(request_method, url, body = nil, headers = {})
        @request_method = request_method
        @uri            = URI(url) rescue nil
        @body           = body
        @headers        = headers
      end

      def add_body(body)
        @body = body
      end

      def add_headers(headers)
        @headers = headers
      end

      # doing this without a gem is rough =(
      def add_multipart_body(parts)
        body = []
        body << "--#{BOUNDARY}\r\n"
        parts.each do |property, value|
          body << "Content-Disposition: form-data; name=\"#{property}\"\r\n\r\n#{value}"
          body << "\r\n--#{BOUNDARY}\r\n"
        end
        @body = body.join
        @headers["Content-Type"] = "multipart/form-data; boundary=#{BOUNDARY}"
      end

      def perform
        response = nil
        begin
          http              = Net::HTTP.new(@uri.host, @uri.port)
          http.use_ssl      = @uri.scheme == "https" ? true : false
          request           = request_class(@request_method).new(@uri.request_uri)
          request.body      = @body if @body

          @headers.each { |header, value| request[header] = value }
          response = http.request(request)
        rescue
          nil
        end
        response
      end

      def request_class(request_method = 'Get')
        request_method = request_method.downcase.capitalize
        "Net::HTTP::#{request_method}".split('::').inject(Object) { |o, c| o.const_get c }
      end

    end

    # NET::HTTP calls downcase on header keys, this is supposed to be ok
    # but hasn't always been so can use this to preserve api_key case
    class StringPreserveCase < String
      def capitalize
        self
      end

      def downcase
        self
      end
    end

  end
end