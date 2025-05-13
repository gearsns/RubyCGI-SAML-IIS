require 'onelogin/ruby-saml'

def saml_settings
  settings = OneLogin::RubySaml::Settings.new
  # 権限が無かったら再認証
  settings.force_authn = true
  # 自分のSP (Service Provider)側設定
  settings.assertion_consumer_service_url = "https://***/acs.rb"
  settings.issuer                         = "https://***/metadata"
  # Entra ID (AzureAD)側設定
  settings.idp_entity_id                  = "https://sts.windows.net/***/"
  settings.idp_sso_target_url             = "https://login.microsoftonline.com/***/saml2"
  settings.idp_cert                       = <<"EOS"
-----BEGIN CERTIFICATE-----
*** [証明書] ***
-----END CERTIFICATE-----
EOS
  # 署名関連（セキュリティ強め）
  settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
  settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  # その他オプション（好みに応じて）
  settings.security[:authn_requests_signed]   = false # SPから送るリクエスト署名するならtrue
  settings.security[:want_assertions_signed]  = true  # 受け取るAssertionに署名要求
  settings.security[:want_assertions_encrypted] = false # 暗号化は基本不要だけど必要ならtrueに
  settings.security[:metadata_signed] = true
  settings.security[:digest_method] = XMLSecurity::Document::SHA256
  settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256

  settings
end

def session_settings
  {
    "tmpdir" => "C:/temp/session", # 適宜変更
    "session_key" => "MYSESSION",
    "session_path" => "/" # すべてのパスでセッションが共有されるように
  }
end