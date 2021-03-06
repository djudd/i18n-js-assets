# encoding: UTF-8

require 'fileutils'

module I18nJsAssets
  class Entry
    attr_reader :app, :source_path, :target_path, :options

    def initialize(app, source_path, target_path, options)
      @app = app
      @source_path = source_path
      @target_path = target_path
      @options = options
    end

    def apply!
      each_file do |locale, interpolated_target_path|
        path = "#{interpolated_target_path}.i18njs"
        app.config.assets.generated.add(path, options) do
          source.overwrite('locales' => [locale]).dump
        end
      end
    end

    private

    def source
      @source ||= I18nJsFile.load_file(absolute_source_path.to_s)
    end

    def each_file
      if block_given?
        locales.each do |locale|
          interpolated_target_path = target_path % { locale: locale }
          yield locale, interpolated_target_path
        end
      else
        to_enum(__method__)
      end
    end

    def absolute_source_path
      app.assets.resolve(source_path)
    end

    def locales
      if locs = options[:precompile]
        locs.respond_to?(:call) ? locs.call : locs
      else
        if Kernel.const_defined?(:I18n)
          I18n.available_locales
        else
          []
        end
      end
    end
  end
end
