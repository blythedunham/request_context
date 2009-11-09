class RequestContext
  def self.controller
    Thread.current[:request_context]
  end

  def self.controller=( controller )
    Thread.current[:request_context] = controller
  end

  def self.with_controller( controller, clear = true, &block )
    last_request_controller = self.controller unless clear
    self.controller = controller
    yield
  ensure
    self.controller = last_request_controller
  end

  private
  def self.method_missing(method, *arguments, &block)
    return if controller.nil?
    controller.__send__(method, *arguments, &block)
  end
end

ActionController::Base.class_eval do
  def perform_action_with_request_context( *arguments )
    RequestContext.with_controller( self ) do
      perform_action_without_request_context( *arguments )
    end
  end

  alias_method_chain :perform_action, :request_context unless method_defined?( :perform_action_without_request_context )
end
