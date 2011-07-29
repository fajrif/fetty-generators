class <%= controller_name %> < ApplicationController
  
<%- if action? :index -%>
  def index
    search = <%= class_name %>.where('<%= model_attributes[0].name %> LIKE ?', "%#{params[:search]}%")
    search = search.order(params[:sort] + " " + params[:direction]) unless params[:sort].blank? && params[:direction].blank?

    <%= instances_name('@') %> = search.page(params[:page]).per(10)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => <%= instances_name('@') %> }
      format.js
    end
  end
<%- end -%>  
<%- if action? :show -%>
  def show
    <%= instance_name('@') %> = <%= class_name %>.find(params[:id])
  end
<%- end -%>  
<%- if action? :new -%>
  def new
    <%= instance_name('@') %> = <%= class_name %>.new
  end
<%- end -%>  
<%- if action? :create -%>
  def create
    <%= instance_name('@') %> = <%= class_name %>.new(params[<%= instance_name(':') %>])
    if <%= instance_name('@') %>.save
      redirect_to <%= generate_route_link(:action => :show, :suffix => 'path', :object => instance_name('@')) %>, :notice => "Successfully created <%= simple_name %>."
    else
      render :action => 'new'
    end
  end
<%- end -%>  
<%- if action? :edit -%>
  def edit
    <%= instance_name('@') %> = <%= class_name %>.find(params[:id])
  end
<%- end -%>  
<%- if action? :update -%>
  def update
    <%= instance_name('@') %> = <%= class_name %>.find(params[:id])
    if <%= instance_name('@') %>.update_attributes(params[<%= instance_name(':') %>])
      redirect_to <%= generate_route_link(:action => :show, :suffix => 'path', :object => instance_name('@')) %>, :notice  => "Successfully updated <%= simple_name %>."
    else
      render :action => 'edit'
    end
  end
<%- end -%>  
<%- if action? :destroy -%>
  def destroy
    <%= instance_name('@') %> = <%= class_name %>.find(params[:id])
    <%= instance_name('@') %>.destroy
    redirect_to <%= generate_route_link(:action => :index, :suffix => 'url') %>, :notice => "Successfully destroyed <%= simple_name %>."
  end
<%- end -%>
  
end
