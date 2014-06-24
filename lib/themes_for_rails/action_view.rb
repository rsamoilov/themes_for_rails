# encoding: utf-8
include ActionView::Helpers::AssetTagHelper
module ThemesForRails
  
  module ActionView

    extend ActiveSupport::Concern

    included do
      include ThemesForRails::CommonMethods
    end

    def base_theme_javascript_path(options)
      theme_dir = ThemesForRails.config.themes_routes_dir
      "/#{theme_dir}/#{options[:theme]}/javascripts/#{options[:asset]}"
    end

    def base_theme_stylesheet_path(options, extra = {})
      Rails.logger.debug options
      theme_dir = ThemesForRails.config.themes_routes_dir
      Rails.logger.debug theme_dir
      "/#{theme_dir}/#{options[:theme]}/stylesheets/#{options[:asset]}"
    end

    def base_theme_image_path(options, extra = {})
      theme_dir = ThemesForRails.config.themes_routes_dir
      "/#{theme_dir}/#{options[:theme]}/images/#{options[:asset]}"
    end

    def current_theme_stylesheet_path(asset)
      base_theme_stylesheet_path(:theme => self.theme_name, :asset => "#{asset}.css")
    end
    
    def current_theme_javascript_path(asset)
      base_theme_javascript_path(:theme => self.theme_name, :asset => "#{asset}.js")
    end

    def current_theme_image_path(asset)
      base_theme_image_path(:theme => self.theme_name, :asset => asset)
    end

    def theme_stylesheet_path(asset, new_theme_name = self.theme_name)
      base_theme_stylesheet_path(:theme => new_theme_name, :asset => "#{asset}.css")
    end

    def theme_javascript_path(asset, new_theme_name = self.theme_name)
      base_theme_javascript_path(:theme => new_theme_name, :asset => "#{asset}.js")
    end

    def theme_image_path(asset, new_theme_name = self.theme_name)
      base_theme_image_path(:theme => new_theme_name, :asset => asset)
    end
    
    def theme_image_tag(source, options = {})
      image_tag(theme_image_path(source), options)
    end

    def theme_image_submit_tag(source, options = {})
      image_submit_tag(theme_image_path(source), options)
    end

    def theme_javascript_include_tag(*files)
      options = files.extract_options!
      options.merge!({ :type => "text/javascript" })
      files_with_options = files.collect {|file| theme_javascript_path(file) }
      files_with_options += [options]

      javascript_include_tag(*files_with_options)
    end

    def theme_stylesheet_link_tag(*files)
      options = files.extract_options!
      options.merge!({ :type => "text/css" })
      files_with_options = files.collect {|file| theme_stylesheet_path(file) }
      files_with_options += [options]

      stylesheet_link_tag(*files_with_options)
    end

    def theme_stylesheet_link_tag_for_liquid(*files)
      options = files.extract_options!
      self.theme_name = options.delete(:theme_name)
      options.merge!({ :type => "text/css" })
      files_with_options = files.collect {|file| theme_stylesheet_path(file) }
      files_with_options += [options]
      Rails.logger.debug files_with_options
      stylesheet_link_tag(*files_with_options)
    end

    def theme_javascript_include_tag_for_liquid(*files)
      options = files.extract_options!
      self.theme_name = options.delete(:theme_name)
      options.merge!({ :type => "text/javascript" })
      files_with_options = files.collect {|file| theme_javascript_path(file) }
      files_with_options += [options]
      Rails.logger.debug files_with_options
      javascript_include_tag(*files_with_options)
    end

    def theme_image_tag_for_liquid(source, options)
      self.theme_name = options.delete(:theme_name)
      theme_image_tag(source, options)
    end
  end
end
