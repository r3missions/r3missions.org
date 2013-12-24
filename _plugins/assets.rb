require "jekyll-assets"
require "jekyll-assets/compass"
require "sprockets"

bower_components = File.expand_path("../bower_components", __dir__)

Sprockets.append_path File.join(__dir__, "../_assets/vendor")

%w[ jquery modernizr ].each do |path|
  Sprockets.append_path File.join(bower_components, path)
end
