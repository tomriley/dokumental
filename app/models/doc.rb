class Doc < ActiveRecord::Base
  attr_accessible :title, :permalink, :content, :parent_id, :author_id
  acts_as_nested_set
  validates_presence_of :title
  validates_uniqueness_of :title
  has_permalink :title
  attr_accessor :static
  acts_as_versioned
  self.non_versioned_columns += %w(parent_id lft rgt)
  
  def static?
    static
  end
  
  def to_param
    permalink
  end
  
  def self.root_docs
    roots = Doc.roots
    roots.reject {|d| d.permalink == 'home'}
  end
  
  def self.home_exists?
    doc_exists?('home')
  end
  
  def self.find_doc(permalink)
    static_docs[permalink] || Doc.find_by_permalink(permalink)
  end
  
  def self.doc_exists?(permalink)
    !static_docs[permalink].nil? || Doc.exists?(:permalink => permalink)
  end
  
  def self.find_static(permalink)
    static_docs[permalink]
  end
  
  def self.sanitize_filename(filename)
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''
      # Finally, replace all non alphanumeric, underscore
      # or periods with underscore
      name.gsub! /[^\w\.\-]/, '_'
    end
  end
  
  # Get hash from static doc permalink to (unpersisted) Doc object
  def self.static_docs
    if !@static_docs
      logger.info "Loading static docs from RAILS_ROOT/app/docs..."
      @static_docs = {}
      docs = File.join(RAILS_ROOT, 'app', 'docs')
      return @static_docs unless File.exists?(docs)
      Dir.foreach(docs) do |fname|
        unless fname =~ /^./ || File.directory?(File.join(docs, fname))
          lines = File.read(File.join(docs, fname)).lines.to_a
          doc = Doc.new(:title => lines.shift.strip, :content => lines.join)
          doc.static = true
          doc.permalink = fname
          @static_docs[fname] = doc
        end
      end
      logger.info "Loaded #{@static_docs.size} static docs."
    end
    @static_docs
  end
  
end

# == Schema Information
#
# Table name: docs
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  permalink  :string(255)
#  content    :text
#  parent_id  :integer(4)
#  lft        :integer(4)
#  rgt        :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

