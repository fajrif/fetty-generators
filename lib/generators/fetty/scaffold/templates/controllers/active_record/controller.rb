class <%= plural_class_name %>Controller < ApplicationController
  
<%- if action? :index -%>
  def index
	  @search = <%= class_name %>.search(params[:search])
    @<%= instances_name %> = @search.page(params[:page]).per(10)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= instances_name %> }
      format.js
    end
  end
<%- end -%>  
<%- if action? :show -%>
  def show
    @<%= instance_name %> = <%= class_name %>.find(params[:id])
  end
<%- end -%>  
<%- if action? :new -%>
  def new
    @<%= instance_name %> = <%= class_name %>.new
  end
<%- end -%>  
<%- if action? :create -%>
  def create
    @<%= instance_name %> = <%= class_name %>.new(params[:<%= instance_name %>])
    if @<%= instance_name %>.save
      redirect_to <%= items_url %>, :notice => "Successfully created <%= class_name.underscore.humanize.downcase %>."
    else
      render :action => 'new'
    end
  end
<%- end -%>  
<%- if action? :edit -%>
  def edit
    @<%= instance_name %> = <%= class_name %>.find(params[:id])
  end
<%- end -%>  
<%- if action? :update -%>
  def update
    @<%= instance_name %> = <%= class_name %>.find(params[:id])
    if @<%= instance_name %>.update_attributes(params[:<%= instance_name %>])
      redirect_to <%= items_url %>, :notice  => "Successfully updated <%= class_name.underscore.humanize.downcase %>."
    else
      render :action => 'edit'
    end
  end
<%- end -%>  
<%- if action? :destroy -%>
  def destroy
    @<%= instance_name %> = <%= class_name %>.find(params[:id])
    @<%= instance_name %>.destroy
    redirect_to <%= items_url %>, :notice => "Successfully destroyed <%= class_name.underscore.humanize.downcase %>."
  end
<%- end -%>
  
end
