require "httparty"
require "cgi"
require Rails.root.join("config", "autogradeConfig.rb")

##
# Ruby API Client of Tango
module TangoClient
  # Exception for Tango API Client
  class TangoException < StandardError; end

  # Retries for http operations
  NUM_RETRIES = 3
  RETRY_WAIT_TIME = 2 # seconds
  
  # Httparty client for Tango API
  class TangoClientObj
    include HTTParty
    default_timeout 30
    
    def get(path, options = {}, &block)
      url = HTTParty.normalize_base_uri("#{@host}:#{@port}")
      HTTParty.get(url+path, options, &block)
    end
    
    def post(path, options = {}, &block)
      url = HTTParty.normalize_base_uri("#{@host}:#{@port}")
      HTTParty.get(url+path, options, &block)
    end
    
    def initialize(host, port, key, timeout)
      @host = host
      @port = port
      @timeout = timeout
      @api_key = key
    end
    
    def handle_exceptions
      begin
        retries_remaining ||= NUM_RETRIES
        resp = yield
      rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error,
             Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE => e
        if retries_remaining > 0
          retries_remaining -= 1
          sleep RETRY_WAIT_TIME
          retry
        else
          raise TangoException, "Connection error with Tango (#{e})."
        end
      rescue StandardError => e
        raise TangoException, "Unexpected error with Tango (#{e})."
      end

      if resp.content_type == "application/json" && resp["statusId"] && resp["statusId"] < 0
        raise TangoException, "Tango returned negative status code: #{resp["statusId"]}"
      end
      return resp
    end

    def open(courselab)
      resp = handle_exceptions do
        url = "/open/#{@api_key}/#{courselab}/"
        self.get(url)
      end
      resp["files"]
    end

    def upload(courselab, filename, file)
      handle_exceptions do
        url = "/upload/#{@api_key}/#{courselab}/"
        self.post(url, headers: { "filename" => filename }, body: file)
      end
    end

    def addjob(courselab, options = {})
      handle_exceptions do
        url = "/addJob/#{@api_key}/#{courselab}/"
        self.post(url, body: options)
      end
    end

    def self.poll(courselab, output_file)
      handle_exceptions do
        url = "/poll/#{@api_key}/#{courselab}/#{output_file}"
        self.get(url)
      end
    end

    def self.info
      resp = handle_exceptions do
        url = "/info/#{@api_key}/"
        self.get(url)
      end
      resp["info"]
    end

    def self.jobs(deadjobs = 0)
      resp = handle_exceptions do
        url = "/jobs/#{@api_key}/#{deadjobs}/"
        self.get(url)
      end
      resp["jobs"]
    end

    def self.pool(image = nil)
      resp = handle_exceptions do
        url = image.nil? ? "/pool/#{@api_key}/" : "/pool/#{@api_key}/#{image}/"
        self.get(url)
      end
      resp["pools"]
    end

    def self.prealloc(image, num, options = {})
      handle_exceptions do
        url = "/prealloc/#{@api_key}/#{image}/#{num}/"
        self.get(url, body: options)
      end
    end
  end

  def self.default()
    return TangoClientObj.new(RESTFUL_HOST, RESTFUL_PORT, RESTFUL_KEY, AUTOCONFIG_TANGO_TIMEOUT)
  end
    
  def self.with(tangoRecord)
    return TangoClientObj.new(tangoRecord.host, tangoRecord.port, tangoRecord.key, tangoRecord.timeout)
  end
    
end
