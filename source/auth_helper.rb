require 'cgi'
require 'cgi/session'
require_relative 'config'
require 'logger'

def ensure_authenticated
  cgi = CGI.new
  session = CGI::Session.new(cgi, session_settings)

  if session['userid']
    #if 権限チェック # ここで権限チェックしてOKの場合だけ
      return [cgi, session, permit]
    #end
  end
  session['userid'] = nil
  # セッションに元URLを記録しておく
  session['return_to'] = "https://#{ENV['HTTP_HOST']}#{ENV['PATH_INFO']}"
  begin
    # SAML認証リクエスト発行
    #  Railsを使用しない場合(CGI等)、LoggerがSTDOUTに出力されるようになっているので適宜、出力先を変更する。
    OneLogin::RubySaml::Logging.logger = ::Logger.new(StringIO.new)
    request = OneLogin::RubySaml::Authrequest.new
    sso_url = request.create(saml_settings)
    print cgi.header("status" => "302 Found", "location" => sso_url)
    exit
  rescue
    print cgi.header("type" => "text/html")
    puts "<h1>SAML Authentication Failed #{session['return_to']}</h1>"
    exit
  end
end