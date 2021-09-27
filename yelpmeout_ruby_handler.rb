require 'json'
require 'snark'
require 'recommendation_generator'

def lambda_handler(event:, context:)
  location = 'San Francisco' # TODO: swap with real thing
  generator = RecommendationGenerator.new(location)
  businesses = generator.fake_recommendations

  business_sections = businesses.map do |business|
    star_text = (0..business[:rating].to_i).map { ':star:' }.join('')
    mrkdown = "*#{business[:name]}*\n"
    mrkdown += "#{star_text} #{business[:review_count]} reviews\n" if business[:review_count] > 0
    mrkdown += "Price range:#{business[:price]}\n" unless business[:price].nil?
    mrkdown += "Location: #{business[:location]}" unless business[:location].empty?

    {
      'type': 'section',
      'text': {
        'type': 'mrkdwn',
        'text': mrkdown
      },
      'accessory': {
        'type': 'image',
        'image_url': business[:image_url],
        'alt_text': business[:alias]
      }
    }
  end

  test_block = [
    Snark.snarkdown,
    {
      "type": 'divider'
    },
    business_sections,
    {
      "type": 'divider'
    }
  ]

  JSON.generate({ statusCode: 200, blocks: test_block.flatten })
end
