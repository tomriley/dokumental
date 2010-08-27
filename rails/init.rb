if defined?(ActionView)
  require 'dokumental/helper'
  ActionView::Base.class_eval do
    include Dokumental::Helper
  end
end

%w{ models controllers }.each do |dir|
  path = File.expand_path File.join(File.dirname(__FILE__), '..', 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end