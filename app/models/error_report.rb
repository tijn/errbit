require 'hoptoad_notifier'

##
# Processes a new error report.
#
# Accepts a hash with the following attributes:
#
# * <tt>:error_class</tt> - the class of error
# * <tt>:message</tt> - the error message
# * <tt>:backtrace</tt> - an array of stack trace lines
#
# * <tt>:request</tt> - a hash of values describing the request
# * <tt>:server_environment</tt> - a hash of values describing the server environment
#
# * <tt>:notifier</tt> - information to identify the source of the error report
#
class ErrorReport
  attr_reader :error_class, :message, :request, :server_environment, :api_key,
              :notifier, :user_attributes, :framework, :notice

  def initialize(xml_or_attributes)
    @attributes = xml_or_attributes
    @attributes = Hoptoad.parse_xml!(@attributes) if @attributes.is_a? String
    @attributes = @attributes.with_indifferent_access
    @attributes.each { |k, v| instance_variable_set(:"@#{k}", v) }
  end

  def rails_env
    rails_env = server_environment['environment-name']
    rails_env = 'development' if rails_env.blank?
    rails_env
  end

  def app
    @app ||= App.where(:api_key => api_key).first
  end

  def backtrace
    @normalized_backtrace ||= Backtrace.find_or_create(:raw => @backtrace)
  end

  def generate_notice!
    return unless valid?
    return @notice if @notice
    @notice = build_notice
    @notice.backtrace_id = backtrace.id
    error.notices << @notice
    @notice
  end

  ##
  # Error associate to this error_report
  #
  # Can already exist or not
  #
  # @return [ Error ]
  def error
    @error ||= app.find_or_create_err!(
      :error_class => error_class,
      :environment => rails_env,
      :fingerprint => fingerprint
    )
  end

  def valid?
    !!app
  end

  def should_keep?
    current_version? && passes_filters?
  end

  private

  def current_version?
    app_version = server_environment['app-version'] || ''
    current_version = app.current_app_version
    return true unless current_version.present?
    return false if app_version.length <= 0
    Gem::Version.new(app_version) >= Gem::Version.new(current_version)
  end

  def build_notice
    Notice.new(
      message:            message,
      error_class:        error_class,
      request:            request,
      server_environment: server_environment,
      notifier:           notifier,
      user_attributes:    user_attributes,
      framework:          framework
    )
  end

  def passes_filters?
    app.keep_notice? build_notice
  end

  def fingerprint
    @fingerprint ||= Fingerprint.generate(notice, api_key)
  end

end
