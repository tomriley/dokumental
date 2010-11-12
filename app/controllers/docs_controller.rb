class DocsController < ApplicationController
  before_filter :authenticate_view_doc_action, :only => %w(index show)
  before_filter :authenticate_edit_doc_action, :only => %w(edit update destroy)
  before_filter :authenticate_new_doc_action, :only => %w(index create new)
  respond_to :html
  
  def index
    @updates = Doc::Version.find(:all, :order => 'doc_versions.updated_at DESC', :include => :doc)
    redirect_to doc_path('home') if Doc.home_exists?
  end
  
  def show
    # Prefer static content over db
    @doc = Doc.find_static(params[:id]) || Doc.find_by_permalink(params[:id])
    raise ActiveRecord::RecordNotFound if @doc.nil?
    respond_with(@doc)
  end
  
  def edit
    respond_with(@doc = Doc.find_by_permalink(params[:id]))
  end
  
  def update
    params[:doc][:author_id] = current_doc_author_id
    @doc = Doc.find_by_permalink(params[:id])
    @doc.update_attributes(params[:doc])
    respond_with(@doc)
  end
  
  def create
    params[:doc][:author_id] = current_doc_author_id
    clear_permalink = params[:doc][:permalink].nil? || params[:doc][:permalink].blank?
    @doc = Doc.new(params[:doc])
    if !@doc.save && clear_permalink
      # Clear generated permalink
      @doc.permalink = nil
    end
    respond_with(@doc)
  end
  
  def new
    @doc = Doc.new
    @doc.permalink = params[:permalink] if params[:permalink]
    @doc.parent = Doc.find(params[:parent_id]) if params[:parent_id]
    respond_with(@doc)
  end
  
  def changeset
    @doc = Doc.find_by_permalink(params[:id])
    raise ActiveRecord::RecordNotFound if @doc.nil?
    @revision_to   = @doc.versions.find_by_version(params[:revision])
    @revision_from = @doc.versions.find_by_version(params[:revision].to_i-1)
    @to   = @revision_to.content.split(/(\s+)/).reject(&:blank?)
    @from = (@revision_from.try(:content) || '').split(/(\s+)/).reject(&:blank?)
    @diff = @from.diff(@to)
    @words = @to
  end

protected

  def authenticate_new_doc_action
    raise ActiveRecord::RecordNotFound if !current_user_can_create_doc?
  end
  
  def authenticate_edit_doc_action
    raise ActiveRecord::RecordNotFound if !current_user_can_edit_doc?(Doc.find_by_permalink(params[:id]))
  end
  
  def authenticate_view_doc_action
    raise ActiveRecord::RecordNotFound if !current_user_can_view_doc?(params[:id] ? Doc.find_by_permalink(params[:id]) : nil)
  end
  
end


class WikiDiff
  attr_reader :diff, :words, :content_to, :content_from
  
  def initialize(content_to, content_from)
    @content_to = content_to
    @content_from = content_from
    @words = content_to.split(/(\s+)/)
    @words = @words.select {|word| word != ' '}
    words_from = content_from.split(/(\s+)/)
    words_from = words_from.select {|word| word != ' '}    
    @diff = words_from.diff @words
  end
end