class EpayFormParams
  attr_reader :url_ok, :url_cancel

  def initialize(params, order_number)
    @config = Spree::Gateway::EpayBg.where(type: 'Spree::Gateway::EpayBg', active: true).last.preferences
    @params = default_params.merge params
    @url_ok = return_url
    @url_cancel = cancel_url
  end

  def [](key)
    @params.fetch key
  end

  def encoded
    return @encoded if defined? @encoded
    @encoded = EpaySigner.encrypt @params
  end

  def checksum
    return @checksum if defined? @checksum
    @checksum = EpaySigner.checksum encoded, @config[:secret]#EpayConfig.secret
  end

  def post_url
    @config[:post_url]#'https://demo.epay.bg/'#EpayConfig.service_url
  end

  def page
    'credit_paydirect'#'paylogin'#'credit_paydirect'
  end

  def store_url
    store_url = Spree::Store.current.url.sub(/^\w+:\/\//, '')
  end

  def return_url(order_number)
    "#{store_url}/orders/#{order_number}"
  end

  def cancel_url(order_number)
    "#{store_url}/order/#{order_number}/epay/cancel"
  end

  def default_params
    {
      min: @config[:merchant_id],#EpayConfig.min,
      encoding: 'utf-8',
    }
  end
end
