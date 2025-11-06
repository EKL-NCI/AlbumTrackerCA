require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module AlbumTrackCa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Ignore some lib subdirectories
    config.autoload_lib(ignore: %w[assets tasks])

    # Use MiniMagick for Active Storage variants
    config.active_storage.variant_processor = :mini_magick
  end
end
