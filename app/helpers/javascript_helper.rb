module JavascriptHelper
  def render_javascript_data
    data = {}
    if user_signed_in?
      data[:user] = {
        id: current_user.id,
        email: current_user.email.gsub(/@|\./, '')
      }
    end
    javascript_tag("window.APP = window.APP || {};window.APP.rails = #{data.to_json};")
  end
end
