require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Lunar
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Overrides the Rails 8.1 framework default for `preload_links_header`,
    # which emits `Link: <...>; rel=preload` HTTP headers for stylesheets.
    # Chromium never matches header-initiated preloads with <link rel="stylesheet">
    # requests (credentials-mode mismatch), so the preloads are never used and
    # the console warns. The layout already links the CSS in <head>, so the
    # header is redundant.
    config.action_view.preload_links_header = false

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
