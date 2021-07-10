class ApplicationController < ActionController::Base
  private

  def set_alert(type:, title:, body:)
    allowed_type = %w[success danger warning info]
    raise ArgumentError unless title.to_s.in?(allowed_type)
    @alert = {type: type, title: title, body: body}
  end
end
