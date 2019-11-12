# frozen_string_literal: true

# Copyright 2019 簡煒航 (Jian Weihang) <https://tonytonyjan.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'openssl'
require 'base64'
require 'net/http'
require 'uri'
require 'json'
require 'time'

class PtxClient
  ENDPOINT = URI('https://ptx.transportdata.tw/MOTC')

  class ResponseError < RuntimeError
    attr_reader :response

    def initialize(response)
      super response.code
      @response = response
    end
  end

  def initialize(app_id:, app_key:)
    @app_id = app_id
    @app_key = app_key
  end

  def get(path, **params)
    path = "#{ENDPOINT.path}#{path}?#{URI.encode_www_form(params)}"
    x_date = Time.now.httpdate
    headers = {
      'Accept' => 'application/json',
      'Authorization' => %(hmac username="#{@app_id}", algorithm="hmac-sha1", headers="x-date", signature="#{hmac_signature(@app_key, x_date)}"),
      'x-date' => x_date
    }
    request = Net::HTTP::Get.new(path, headers)
    response = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: ENDPOINT.scheme == 'https') do |http|
      http.request(request)
    end
    raise ResponseError, response unless response.is_a? Net::HTTPOK

    JSON.parse(response.body)
  end

  private

  def hmac_signature(key, x_date)
    Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', key, "x-date: #{x_date}"))
  end
end
