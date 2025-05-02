#!/usr/bin/env ruby
require 'cgi'
require 'cgi/session'
require 'onelogin/ruby-saml'
require_relative 'config'

cgi = CGI.new
session = CGI::Session.new(cgi, session_settings)
begin
  if cgi.params["SAMLResponse"].any?
    response = OneLogin::RubySaml::Response.new(cgi.params['SAMLResponse'][0], settings: saml_settings)
    if response.is_valid?
      OneLogin::RubySaml::Attributes.single_value_compatibility = true
      session['userid'] = response.nameid
      # 属性とクレーム
      #session['mail'] = response.attributes["mail"]
      #session['displayname'] = response.attributes["displayname"]
      # 保存していた「元のURL」へリダイレクト
      return_to = session['return_to'] || "/" #"./index.rb"  # デフォルト fallback
      if session['return_to']
        session['return_to'] = nil
      end
      session.close
      print cgi.header("status" => "302 Found", "location" => return_to, "X-User-Id" => session['userid'])
    else
      raise "SAML Authentication Failed!"
    end
  else
    raise "SAML Authentication Failed!"
  end
rescue
  session.close
  print cgi.header("type" => "text/html")
  puts "<h1>SAML Authentication Failed</h1>"
end
