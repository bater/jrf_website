class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :set_catalog, :set_article_q, :except => [:change_locale,:set_locale]
  before_filter :set_locale
  skip_before_action :verify_authenticity_token, only: [:change_locale]

  def change_locale
    locale = params[:locale].to_i == 0 ? "en" : "zh-TW"
    I18n.locale = locale
    session[:locale] = locale
    redirect_to :back
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.uuid
    payload[:user_id] = current_user.id if current_user
    if request.env['HTTP_CF_CONNECTING_IP']
      payload[:ip] = request.env['HTTP_CF_CONNECTING_IP']
    elsif request.env["HTTP_X_FORWARDED_FOR"]
      payload[:ip] = request.env["HTTP_X_FORWARDED_FOR"]
    else
      payload[:ip] = request.env['REMOTE_ADDR']
    end
  end

  private

  def set_catalog
    @catalogs = Catalog.includes(:categories).all
  end

  def set_article_q
    @article_q = Article.search(params[:q])
  end

  def after_sign_in_path_for(resource)
    if current_user.admin
      request.env['omniauth.origin'] || stored_location_for(resource) || admin_catalogs_path
    else
      sign_out current_user
      root_path
    end
  end

  def sanitize(html)
    Nokogiri::HTML(html).text
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
