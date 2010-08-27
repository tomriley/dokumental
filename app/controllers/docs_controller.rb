class DocsController < ApplicationController
  before_filter :authenticate_view_doc_action, :only => %w(index show)
  before_filter :authenticate_edit_doc_action, :only => %w(edit update destroy)
  before_filter :authenticate_new_doc_action, :only => %w(index create new)
  respond_to :html
  helper_method :current_user_can_edit_doc?
  helper_method :current_user_can_create_doc?
  helper_method :current_user_can_view_doc?
  
  def index
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
    @doc = Doc.find_by_permalink(params[:id])
    @doc.update_attributes(params[:doc])
    respond_with(@doc)
  end
  
  def create
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