  def index
	@search = <%= class_name %>.search(params[:search])
    @<%= instances_name %> = @search.paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= instances_name %> }
      format.js
    end
  end