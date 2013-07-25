# Jekyll sitemap page generator.
#
# Copyright (c) 2013 Laszlo Bacsi
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# Generator that creates a sitemap.xml page for jekyll sites.

module Jekyll

  class SitemapFile < StaticFile
    def initialize(site, dir, name, contents)
      @contents = contents
      super(site, site.dest, dir, name)
    end

    def write(dest)
      dest_path = destination(dest)

      return false if File.exist?(dest_path) and File.read(dest_path) == @contents

      FileUtils.mkdir_p(File.dirname(dest_path))
      File.open(dest_path, 'w') {|f| f.write(@contents)}

      true
    end
  end

  # Generates a sitemap.xml file containing URLs of all pages and posts.
  class SitemapGenerator < Generator
    safe true
    priority :low

    def generate(site)
      sitemap = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
#{generate_content(site)}</urlset>
      EOS

      site.static_files << SitemapFile.new(site, '/', 'sitemap.xml', sitemap)
    end

    private

    def generate_content(site)
      entries = []

      site.pages.each do |page|
        next if page.url =~ /\.(sass|scss|css)$/
        next if page.data['sitemap'] == false

        source_file = site.source + '/' + page.path
        next unless File.exist?(source_file)
        mtime = File.mtime(source_file)

        path = page.url.sub(/\/index\.html$/, '')

        entries << entry(path, mtime, attributes(page), site)
      end

      site.posts.each do |post|
        next if post.data['sitemap'] == false

        path = post.url
        path = '/' + path unless path =~ /^\//
        path.sub!(/\/index.html$/, '')

        entries << entry(path, post.date, attributes(post), site)
      end

      entries.join("")
    end

    def attributes(page)
      attrs = {}
      attrs[:changefreq] = page.data['changefreq'] if page.data.has_key?('changefreq')
      attrs[:priority] = page.data['priority'] if page.data.has_key?('priority')
      attrs
    end

    # Creates an XML entry from the given path and date.
    def entry(path, date, attrs, site)
      # Remove the trailing slash from the baseurl if it is present, for consistency.
      baseurl = site.config['baseurl'].sub(/\/$/, '')

      <<-EOS
<url>
  <loc>#{baseurl}#{path}</loc>
  <lastmod>#{date.strftime("%Y-%m-%d")}</lastmod>#{"\n  " + attrs.map {|k,v| "<#{k}>#{v}</#{k}>"}.join("") unless attrs.empty?}
</url>
      EOS
    end

  end

end
