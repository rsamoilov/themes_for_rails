module ThemesForRails
  class LiquidDatabseFileSystem < Liquid::LocalFileSystem
    include ThemesForRails::Interpolation
    attr_accessor :root, :root_no_path, :default_root

    def initialize(root, account, pattern = "_%s.liquid".freeze)
      @root_no_path = root
      @account = account
      @root = interpolate(ThemesForRails.config.snippets_dir, @account.theme.path)
      @default_root = interpolate(ThemesForRails.config.default_snippets_dir)
      @pattern = pattern
      @pattern_no_ext = "_%s".freeze 
    end

    def read_template_file(template_path, context)
      full_path = full_path_no_ext(template_path)
      conditions = {
        :path => full_path,
        :account_id => @account.id,
        :theme_id => @account.theme.id
      }
      
      if @account.tc('view.no_database_template_lookup').blank? and ThemesForRails.config.database_enabled and (record = CustomTemplate.where(conditions).first)
        record.content
      else

        full_path    = full_path(template_path)
        default_path = default_full_path(template_path)
        theme_path   = theme_full_path(template_path)

        if File.exists?(full_path)
          File.read(full_path)

        elsif theme_path and File.exists?(theme_path)
          File.read(theme_path)

        elsif File.exists?(default_path)
          File.read(default_path)
        end
      end

    end

    def full_path_no_ext(template_path)
      raise FileSystemError, "Illegal template name '#{template_path}'" unless template_path =~ /\A[^.\/][a-zA-Z0-9_\/]+\z/

      full_path = if template_path.include?('/'.freeze)
        File.join(root_no_path, File.dirname(template_path), @pattern_no_ext % File.basename(template_path))
      else
        File.join(root_no_path, @pattern_no_ext % template_path)
      end
      
      raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /\A#{File.expand_path(root_no_path)}/

      full_path
    end

    def theme_full_path(template_path)
      return if @account.tc('view.theme').blank?
      default_full_path(template_path).to_s.sub('/themes/default/', "/themes/#{@account.tc('view.theme')}/")
    end

    def default_full_path(template_path)
      raise FileSystemError, "Illegal template name '#{template_path}'" unless template_path =~ /\A[^.\/][a-zA-Z0-9_\/]+\z/

      full_path = if template_path.include?('/'.freeze)
        File.join(default_root, File.dirname(template_path), @pattern % File.basename(template_path))
      else
        File.join(default_root, @pattern % template_path)
      end
      raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /\A#{File.expand_path(default_root)}/

      full_path
    end
  end
end