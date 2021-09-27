require 'json'
require 'uri'
require 'net/http'

class RecommendationGenerator
  YELP_BUSINESS_SEARCH_URL = 'https://api.yelp.com/v3/businesses/search'.freeze
  METERS_IN_A_MILE = 1609.34

  def initialize(location)
    @location = location
  end

  def fake_recommendations
    [
      { name: 'Lime Tree Southeast Asian Kitchen', location: '836 Clement St San Francisco, CA 94118',
        image_url: 'https://s3-media1.fl.yelpcdn.com/bphoto/5NtTk7G53ZtK1sLsz6rpIw/o.jpg', price: '$$', rating: 4.5, url: 'https://www.yelp.com/biz/lime-tree-southeast-asian-kitchen-san-francisco-2?adjust_creative=q2Czh7d0-PQFIu4TPntGyA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=q2Czh7d0-PQFIu4TPntGyA', review_count: 362, alias: 'lime-tree-southeast-asian-kitchen-san-francisco-2' }, { name: 'Perilla', location: '836 Irving St San Francisco, CA 94122', image_url: 'https://s3-media2.fl.yelpcdn.com/bphoto/gEn6tWCzzZtCmhrjpfcUZA/o.jpg', price: '$$', rating: 4.0, url: 'https://www.yelp.com/biz/perilla-san-francisco-2?adjust_creative=q2Czh7d0-PQFIu4TPntGyA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=q2Czh7d0-PQFIu4TPntGyA', review_count: 1388, alias: 'perilla-san-francisco-2' }, { name: 'Souvla', location: '531 Divisadero St San Francisco, CA 94117', image_url: 'https://s3-media3.fl.yelpcdn.com/bphoto/kzOK8tthxodXt9_oSMlSnA/o.jpg', price: '$$', rating: 4.0, url: 'https://www.yelp.com/biz/souvla-san-francisco-3?adjust_creative=q2Czh7d0-PQFIu4TPntGyA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=q2Czh7d0-PQFIu4TPntGyA', review_count: 497, alias: 'souvla-san-francisco-3' }, { name: 'Osteria Bella', location: '3848 Geary Blvd San Francisco, CA 94118', image_url: 'https://s3-media2.fl.yelpcdn.com/bphoto/FKp7GNDf-9os_zR4Is1zqA/o.jpg', price: '$$', rating: 4.5, url: 'https://www.yelp.com/biz/osteria-bella-san-francisco-2?adjust_creative=q2Czh7d0-PQFIu4TPntGyA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=q2Czh7d0-PQFIu4TPntGyA', review_count: 135, alias: 'osteria-bella-san-francisco-2' }
    ]
  end

  def generate_recommendations(num_of_recs)
    initial_query_body = JSON.parse(businesses_query(location: @location))
    available_offsets = initial_query_body['total'] - 50

    random_businesses = (0..num_of_recs).map do
      random_offset = rand(0..available_offsets)
      resp = JSON.parse(businesses_query(location: @location, offset: random_offset))
      resp['businesses'].sample
    end

    random_businesses.map do |biz|
      {
        name: biz['name'],
        location: (biz.dig('location', 'display_address') || []).join(' '),
        image_url: biz['image_url'],
        price: biz['price'],
        rating: biz['rating'],
        url: biz['url'],
        review_count: biz['review_count'],
        alias: biz['alias']
      }
    end
  end

  def businesses_query(location:, offset: 0, miles_radius: 5)
    uri = URI(YELP_BUSINESS_SEARCH_URL)
    params = {
      location: location,
      radius: (miles_radius * METERS_IN_A_MILE).to_i,
      term: 'restaurants',
      open_now: true,
      transactions: 'delivery',
      limit: 50,
      offset: offset
    }

    headers = { authorization: "Bearer #{ENV['YELP_API_KEY']}" }

    uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{ENV['YELP_API_KEY']}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end

    res.body
  end
end
