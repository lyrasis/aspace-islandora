require 'net/http'
require 'securerandom'
require 'uri'

class Islandora
  attr_accessor :config

  def initialize(config = {})
    # fake defaults (that should be overriden by config)
    @config = {
      base_url:  "https://sandbox.islandora.ca",
      rest_path: "/islandora/archivesspace/v1/update",
      username:  "anonymous",
      password:  "nonsense",
    }.merge(config)

    @session = nil
  end

  # check associated event is an ingest event and has matching location to uri
  # islandora.event_eligible? event, "http://sandbox.islandora.ca/islandora/object/islandora:root"
  def event_eligible?(event, uri)
    ingested = event['event_type'] == 'ingestion' rescue nil
    location = event['external_documents'][0]['location'] rescue nil
    event and ingested and location == uri
  end

  # get session / token from islandora
  def login
    request = Request.new("Post", "#{@config[:base_url]}/user/login")

    request.add_multipart_body ({
      name: @config[:username],
      pass: @config[:password],
      form_id: "user_login",
      op: "Log in",
    })

    response = request.perform
    @session = response['Set-Cookie'].split(";")[0] if response and response['Set-Cookie']
    @session
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
    url      = "#{@config[:base_url]}/#{@config[:rest_path]}/islandora:root" # TODO parse pid from uri or remove this?
    request  = Request.new("Put", url, @session, payload.to_s, { "Content-Type" => "application/json" })
    response = request.perform
    response
  end

  # check uri matches islandora base url
  # islandora.uri_eligible? "http://sandbox.islandora.ca/islandora/object/islandora:root"
  def uri_eligible?(uri)
    # TODO: additional checks and balances
    uri =~ /#{Regexp.escape(@config[:base_url])}/
  end

  class Request
    attr_accessor :body, :headers

    BOUNDARY = SecureRandom.hex

    def initialize(request_method, url, session = nil, body = nil, headers = {})
      @request_method = request_method
      @uri            = URI(url) rescue nil
      @session        = session
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
        request['Cookie'] = @session if @session
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

end