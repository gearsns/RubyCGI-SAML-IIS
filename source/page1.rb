#!/usr/bin/env ruby
require_relative 'auth_helper'

cgi, session, permit = ensure_authenticated

print cgi.header("type" => "text/html", "X-User-Id" => session['userid']))
puts "<html><body>"
puts "<h1>Page1</h1>"
puts "こんにちは、#{session['userid']} さん！"
puts "</body></html>"