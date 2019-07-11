require 'textris'
require 'uri'

class AixMessageTestDelivery < Textris::Delivery::Test
  def deliver(to)
    super

    raise 'Message Too Long (Must be <= 70)' \
      if shorten_urls_in_message(message.content).size > 70
  end

  def shorten_urls_in_message(message)
    URI.extract(message)
       .map { |url| [url, 'https://ans.la/UxNyC2'] }.to_h
       .each do |long, short|
      message = message.sub(long, short)
    end

    message
  end
end
