require 'textris'
require 'uri'
require 'net/http'
require 'aix_message_test'

class AixMessageDelivery < Textris::Delivery::Base
  VERSION = '0.1.0'
  API_BASE_URL = 'https://qpd-api.aossms.com/'.freeze
  ENDPOINT = "#{API_BASE_URL}/p11/api/mt.json".freeze
  SHORTEN_URL_ENDPOINT = "#{API_BASE_URL}/p1/api/shortenurl.json".freeze
  MAX_MESSAGE_LENGTH = 70

  class MessageTooLong < StandardError; end
  class SMSDeliveryFailed < StandardError; end
  class URLShorteningFailed < StandardError; end

  def deliver(phone)
    send_message!(phone, shorten_urls_in_message(message.content))
  end

  private

  def send_message!(phone, message)
    raise MessageTooLong, "Too Long Message: #{message.size} length" \
      if message.size > MAX_MESSAGE_LENGTH

    res = post_request(ENDPOINT, params("+#{phone}", message))

    raise SMSDeliveryFailed, res.inspect unless res.is_a?(Net::HTTPOK)

    parsed = JSON.parse(res.body)

    raise SMSDeliveryFailed, parsed['responseMessage'] if parsed['responseCode'] > 0

    parsed
  end

  def post_request(url, params)
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params)
    Net::HTTP.post_form(uri, {})
  end

  def base_params
    {
      token: ENV['AIX_MESSAGE_ACCESS_TOKEN'],
      clientId: ENV['AIX_MESSAGE_CLIENT_ID']
    }
  end

  def params(phone_number, message)
    base_params.merge(
      smsCode: ENV['AIX_MESSAGE_SMS_CODE'],
      phoneNumber: phone_number,
      message: message
    )
  end

  def shorten_url!(url)
    no_short_regex = /[\?\&]no_short\=true/

    return url.remove(no_short_regex) if url =~ no_short_regex

    params = base_params.merge(longUrl: url)
    res = post_request(SHORTEN_URL_ENDPOINT, params)

    raise URLShorteningFailed, res.inspect unless res.is_a?(Net::HTTPOK)

    parsed = JSON.parse(res.body)

    raise URLShorteningFailed, parsed['responseMessage'] if parsed['responseCode'] > 0

    parsed['shortUrl']
  end

  def shorten_url(url)
    shorten_url!(url)
  rescue URLShorteningFailed
    url
  end

  def shorten_urls_in_message(message)
    URI.extract(message)
      .map { |url| [url, shorten_url(url)] }.to_h
      .each do |long, short|
      message = message.sub(long, short)
    end

    message
  end
end
