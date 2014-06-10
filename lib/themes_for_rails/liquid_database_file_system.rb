module ThemesForRails
  class LiquidDatabseFileSystem < Liquid::LocalFileSystem
    include ThemesForRails::Interpolation
    attr_accessor :root, :root_no_path

    def initialize(root, account, pattern = "_%s.liquid".freeze)
      @root_no_path = root
      @account = account
      @root = interpolate(ThemesForRails.config.snippets_dir, @account.theme.path)
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
      if record = CustomTemplate.where(conditions).first
        record.content
      else
        super(template_path, context)
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
  end
end