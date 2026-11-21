require 'fileutils'
require 'uri'
require 'kramdown'

# Generated only from rendered, explicitly public Jekyll documents.
module AiDiscovery
  PAGE_PATHS = %w[about.html education.html purchase.html editorial-policy.html disclaimer.html privacy.html terms.html].freeze

  def self.public_item?(item, now)
    data = item.data
    return false if data['published'] == false || data['sitemap'] == false || data['ai_discovery'] == false
    return false if data['sitemap'].is_a?(Hash) && %w[yes true].include?(data['sitemap']['exclude'].to_s.downcase)
    return false if data['robots'].to_s.downcase.include?('noindex')
    return false if item.respond_to?(:date) && item.date && item.date > now
    true
  end

  def self.md_path(url)
    url.end_with?('/') ? "#{url}index.md" : "#{url}.md"
  end

  def self.markdown(html, canonical)
    html = html.gsub(/\s(?:href|src)=(['"])(.*?)\1/i) do |attribute|
      attribute.sub(Regexp.last_match(2)) do |value|
        begin
          URI.join(canonical, value.strip).to_s
        rescue URI::InvalidURIError
          value
        end
      end
    end
    Kramdown::Document.new(html, input: 'html').to_kramdown
  end

  class Generator < Jekyll::Generator
    priority :lowest
    def generate(site)
      now = site.time
      items = site.posts.docs.select { |p| AiDiscovery.public_item?(p, now) }
      items += site.pages.select { |p| (PAGE_PATHS.include?(p.path) || p.data['ai_discovery'] == true) && AiDiscovery.public_item?(p, now) }
      items.each { |item| item.data['ai_markdown'] = AiDiscovery.md_path(item.url) }
      site.config['ai_discovery_items'] = items
    end
  end

  def self.content_body(output)
    start = output.match(/<div class="post-content">/)
    return nil unless start
    depth = 1
    scanner = /<\/?div\b[^>]*>/i
    scanner_offset = start.end(0)
    while (tag = scanner.match(output, scanner_offset))
      depth += tag[0].start_with?('</') ? -1 : 1
      if depth.zero?
        body = output[start.end(0)...tag.begin(0)]
        return body.split(/<nav class="blog-navigation"/, 2).first
      end
      scanner_offset = tag.end(0)
    end
    nil
  end

  def self.write(site)
    root = site.dest
    items = site.config['ai_discovery_items'] || []
    entries = []
    # Watch builds reuse this site object; remove outputs from the preceding build.
    Array(site.instance_variable_get(:@ai_generated_paths)).each { |path| FileUtils.rm_f(path) }
    generated_paths = []
    items.each do |item|
      output = item.output.to_s
      # Select the page's actual rendered content, excluding navigation and layout.
      body = content_body(output)
      next unless body
      canonical = URI.join(site.config['url'].to_s + '/', site.baseurl.to_s.sub(%r{\A/}, '') + item.url.sub(%r{\A/}, '')).to_s
      title = item.data['heading'] || item.data['title'] || 'Untitled'
      metadata = "# #{title}\n\nPreferred citation: [#{title}](#{canonical})\n\n"
      metadata += "By #{item.data['author']}\n\n" if item.data['author']
      metadata += "Published: #{item.date.strftime('%Y-%m-%d')}\n\n" if item.respond_to?(:date) && item.date
      metadata += "#{item.data['description']}\n\n" if item.data['description']
      path = File.join(root, item.data['ai_markdown'].sub(%r{\A/}, ''))
      FileUtils.mkdir_p(File.dirname(path))
      raise "AI Markdown output conflicts with an existing file: #{path}" if File.exist?(path)
      File.write(path, metadata + markdown(body, canonical))
      generated_paths << path
      entries << [title, canonical, item.data['ai_markdown']]
    end
    directory = "# Hawaii Digital Currency\n\n> Hawaii-focused cryptocurrency, blockchain, and digital currency explainers.\n\nCite the original HTML page linked in each Markdown document.\n\n## Public pages and articles\n\n"
    entries.each do |title, canonical, path|
      markdown_url = URI.join(site.config['url'].to_s + '/', site.baseurl.to_s.sub(%r{\A/}, '') + path.sub(%r{\A/}, '')).to_s
      directory << "- [#{title.gsub(/[\[\]]/, '')}](#{markdown_url}): Original page: #{canonical}\n"
    end
    site.instance_variable_set(:@ai_generated_paths, generated_paths)
    File.write(File.join(root, 'llms.txt'), directory)
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  AiDiscovery.write(site)
end
