  def index
	@search = <%= class_name %>.search(params[:search])
    @<%= instances_name %> = @search.relation.page(params[:page]).per(10)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= instances_name %> }
      format.js
    end
  end