require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'jekyll'
require_relative '../_plugins/ai_discovery'

class AiDiscoveryTest < Minitest::Test
  def test_public_filter_excludes_unpublished_future_and_noindex
    now = Time.now
    item = Struct.new(:data, :date).new({}, now - 60)
    assert AiDiscovery.public_item?(item, now)
    item.data['published'] = false
    refute AiDiscovery.public_item?(item, now)
    item.data['published'] = true
    item.date = now + 3600
    refute AiDiscovery.public_item?(item, now)
    item.date = now - 60
    item.data['robots'] = 'noindex, follow'
    refute AiDiscovery.public_item?(item, now)
  end

  def test_conversion_preserves_links_images_and_text
    result = AiDiscovery.markdown('<p>Read <a href="../source">the source</a>.</p><img src="/image.png" alt="Chart">', 'https://example.com/articles/one/')
    assert_includes result, 'https://example.com/articles/source'
    assert_includes result, '![Chart](https://example.com/image.png)'
  end
end
