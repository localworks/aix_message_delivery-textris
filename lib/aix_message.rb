require 'uri'
require 'net/http'

class AixMessage
  ENDPOINT = "https://qpd-api.aossms.com/p11/api/mt.json".freeze # TODO: 新しいAPIを使う
  SHORTEN_URL_ENDPOINT = "https://sms-api.aossms.com/p1/api/shortenurl.json".freeze

  class SMSDeliveryFailed < StandardError; end
  class URLShorteningFailed < StandardError; end

  def initialize(token: nil, client_id: nil, sms_code: nil)
    @token = token || ENV['AIX_MESSAGE_ACCESS_TOKEN']
    @client_id = client_id || ENV['AIX_MESSAGE_CLIENT_ID']
    @sms_code = sms_code || ENV['AIX_MESSAGE_SMS_CODE']
  end

  def send!(phone, message)
    res = post_request(ENDPOINT, sms_params("+#{phone}", message))

    raise SMSDeliveryFailed, res.inspect unless res.is_a?(Net::HTTPOK)

    parsed = JSON.parse(res.body)

    raise SMSDeliveryFailed, parsed['responseMessage'] if parsed['responseCode'].positive?

    parsed
  end

  def shorten_url!(url)
    params = base_params.merge(longUrl: url)
    res = post_request(SHORTEN_URL_ENDPOINT, params)

    raise URLShorteningFailed, res.inspect unless res.is_a?(Net::HTTPOK)

    parsed = JSON.parse(res.body)

    raise URLShorteningFailed, parsed['responseMessage'] if parsed['responseCode'].positive?

    parsed['shortUrl']
  end

  def shorten_url(url)
    shorten_url!(url)
  rescue URLShorteningFailed
    url
  end

  private

  def post_request(url, params)
    uri = URI.parse(url)
    Net::HTTP.post(uri, URI.encode_www_form(params))
  end

  def base_params
    {
      token: @token,
      clientId: @client_id
    }
  end

  def sms_params(phone_number, message)
    base_params.merge(
      smsCode: @sms_code,
      phoneNumber: phone_number,
      message: message
    )
  end
end
