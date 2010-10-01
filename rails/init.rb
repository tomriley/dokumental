require 'dokumental/diff'

if defined?(ActionView)
  require 'dokumental/helper'
  ActionView::Base.class_eval do
    include Dokumental::Helper
  end
end

%w{ models controllers }.each do |dir|
  path = File.expand_path File.join(File.dirname(__FILE__), '..', 'app', dir)
  $LOAD_PATH << path
  if Rails.version >= "3.0.0"
    ActiveSupport::Dependencies.autoload_paths << path
    ActiveSupport::Dependencies.autoload_once_paths.delete(path)
  else
    ActiveSupport::Dependencies.load_paths << path
    ActiveSupport::Dependencies.load_once_paths.delete(path)
  end
end