# -*- coding: utf-8 -*-
class FacebookController < BaseController
  def oauth
    oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET, Facebook::CALLBACK_URL)
    redirect_to oauth.url_for_oauth_code(:permissions => ['user_photos', 'publish_stream'] )
  end

  def callback
    oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET, Facebook::CALLBACK_URL)
    if params[:code]
      session[:facebook_access_token] = oauth.get_access_token(params[:code])

      if !(user = User.where(facebook_id: facebook_user['id']).first)
        user = User.new(
          facebook_id: facebook_user['id'],
          name: facebook_user['name'],
        )
        user.save
      end

      begin
        # Photo.tagged
        user = User.where(facebook_id: facebook_user['id']).first
        graph = Koala::Facebook::API.new(session[:facebook_access_token])
        result = graph.fql_query("SELECT pid, object_id, src, src_big, created FROM photo where pid in (SELECT pid FROM photo_tag  WHERE subject =  me() limit 5000)")
      end
    else
      # TODO : ERROR HANDLING
      flash[:error] = 'facebookログインに失敗しました'
      redirect_to :root and return
    end
    redirect_to :root
  end
end
