class LineBotController < ApplicationController
  protect_from_forgery except: [:callback] # CSRF対策を無効化するコード

  def callback
  end
end
