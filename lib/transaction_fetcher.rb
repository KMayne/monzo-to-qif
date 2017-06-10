require 'omnistruct'
require 'json'
require 'rest-client'

class TransactionFetcher
  def initialize(access_token, account_id = nil)
    @access_token = access_token
    @account_id = account_id
  end

  def fetch(since: DEFAULT_DATE)
    since = since || DEFAULT_DATE
    account_id = http_get('/accounts')['accounts'].first['id']
    transactions = http_get("/transactions?account_id=#{account_id}&since=#{since.strftime('%FT%TZ')}&expand[]=merchant")
    transactions['transactions'].map{|t| OmniStruct.new(t)}
  end

  private
  # Monzo started Feb 2015 so the default date should capture all transactions
  DEFAULT_DATE = Date.new(2015,1,1)

  def http_get(url)
    JSON.parse(RestClient.get("https://api.monzo.com#{url}", { 'Authorization' => "Bearer #{@access_token}" }))
  end
end
