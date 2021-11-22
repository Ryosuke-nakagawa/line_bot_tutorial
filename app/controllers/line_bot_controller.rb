class LineBotController < ApplicationController
  protect_from_forgery except: [:callback] # CSRF対策を無効化するコード

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE'] # request.envでヘッダーのみ見る HTTP_X_LINE_SIGNATUREで署名を参照=>signatureに代入
    unless client.validate_signature(body, signature) #clientメソッドにアクセスしてLine::Bot::Clientクラスのインスタンスを作成し、validate_signatureメソッドはメッセージボディと署名を引数として受け取り、署名の検証を行う
      return head :bad_request # ステータスコード400を返す
    end
    events = client.parse_events_from(body) # 署名の検証のために文字列で取得したメッセージボディを扱いやすいように配列に変換する。
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'],message)
        end
      end
    end
    head :ok # ステータスコード200(正常)を返す
  end

  private

  def client
    @client ||=Line::Bot::Client.new{|config| # Line::Bot::Clientクラスをインスタンス化 @clientがnilでなければ代入
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"] # 環境変数から設定値を受け取る
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
