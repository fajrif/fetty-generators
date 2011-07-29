module ApplicationHelper
  
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    css_class = column == params[:sort] ? "current #{direction}" : nil
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), { :class => css_class }
  end
  
end
