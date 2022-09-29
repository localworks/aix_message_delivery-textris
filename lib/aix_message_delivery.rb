require 'aix_message_delivery/version'
require 'textris'
require 'aix_message_test_delivery'
require 'aix_message'

class AixMessageDelivery < Textris::Delivery::Base
  MAX_MESSAGE_LENGTH = 660
  SPLITTED_MESSAGE_SEND_INTERVAL = 3 # SMS分割時に順序がおかしくなる場合は増やす
  NO_SHORT_URL_REGEX = /[?&]no_short=true/

  class MessageTooLong < StandardError; end

  def deliver(phone)
    contents = shorten_urls_in_message(message.content)
               .split('<!-- separator -->')

    raise MessageTooLong, "Too Long Message Exists: #{contents.map { |c| [c, c.size] }}" \
      if contents.any? { |c| c.size > MAX_MESSAGE_LENGTH }

    contents.each do |c|
      aix_message.send!(phone, c)
      sleep SPLITTED_MESSAGE_SEND_INTERVAL
    end
  end

  private

  def aix_message
    @aix_message ||= AixMessage.new
  end

  def shorten_urls_in_message(message)
    URI.extract(message)
       .map { |url| [url, shorten_url(url)] }.to_h
       .each do |long, short|
      message = message.sub(long, short)
    end

    message
  end

  def shorten_url(url)
    return url.remove(NO_SHORT_URL_REGEX) if url =~ NO_SHORT_URL_REGEX

    aix_message.shorten_url(url)
  end
end
