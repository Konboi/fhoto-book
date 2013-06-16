# -*- coding: utf-8 -*-
class BaseController < ApplicationController

  def logged_in?
    !current_user.blank?
  end

  def facebook_oauth_required
    redirect_to login_path and return false if !logged_in?
  end

  def current_user
    current_user = User.where(facebook_id: facebook_user['id']).first
  end

  # facebook user を取得
  def facebook_user
    graph = Koala::Facebook::API.new(session[:facebook_access_token])
    begin
      result = graph.get_object("/me/?locale=#{get_locale}")
      return (result=='false' ? {} : result)
    rescue Exception=>e
      return {}
    end
  end

  private

  # 表示言語を切り替える
  def set_locale
    I18n.locale = get_locale
  end

  def get_locale
    session[:locale] ||= I18n.default_locale
  end

  # 表示テンプレートをスマートフォン用に切り替える
  def set_smartphone_format
    request.format = :smartphone if request.smart_phone? && !request.mobile.tablet?
  end
end
