module JavascriptHelper
  def render_javascript_data
    data = {}
    if user_signed_in?
      data[:user] = {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name,
      }
      data[:skyway_key] = ENV['SKYWAY_KEY']
    end
    javascript_tag("window.APP = window.APP || {};window.APP.rails = #{data.to_json};")
  end
end
