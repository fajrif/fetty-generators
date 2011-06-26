class MessagesController < ApplicationController

  def index
    @messagebox = params[:messagebox].blank? ? "inbox" : params[:messagebox]
    @messages = current_user.send(@messagebox).group(:subject_id).page(params[:page]).per(10)

    case @messagebox
    when "trash"
      @options = ["Read","Unread","Delete","Undelete"]
    else
      @options = ["Read","Unread","Delete"]
    end
  end
	
	def show
    unless params[:messagebox].blank?
      message = current_user.send(params[:messagebox]).find(params[:id])
      
      @messages = message.root.subtree
      @parent_id = @messages.last.id
      
      if @messages.last.copies
        @user_tokens = @messages.last.recipient_id
        @parent_id = @messages.last.ancestor_ids.last unless @parent_id.nil?
      else
        @user_tokens = @messages.last.sender_id
      end

      read_unread_messages(true, *@messages)
    end
	end

	def new
	end

	def create
    unless params[:user_tokens].blank? or params[:subject].blank? or params[:content].blank?
      recipients = User.find(params[:user_tokens].split(",").collect { |id| id.to_i })
      if current_user.send_message?(:recipients => recipients, :subject_id => params[:subject_id], :subject => params[:subject], :content => params[:content], :parent_id => params[:parent_id])
          redirect_to messages_url, :notice => 'Successfully send message.'
        else
          flash.now[:alert] = "Unable to send message."
          render "new"
        end
      else
      flash.now[:alert] = "Invalid input for sending message."
      render "new"
    end 
	end

	def update
    unless params[:messages].nil?
      message = current_user.send(params[:messagebox]).find(params[:messages])

      message.each do |message|
        messages = message.root.subtree

        if params[:option].downcase == "read"
          read_unread_messages(true,*messages)  
        elsif params[:option].downcase == "unread"
          read_unread_messages(false,*messages)
        elsif params[:option].downcase == "delete"
          delete_messages(true,*messages)
        elsif params[:option].downcase == "undelete"
          delete_messages(false,*messages)
        end
      end
    end
    redirect_to messages_url(params[:messagebox]) 
	end

	def empty
   unless params[:messagebox].nil?
      current_user.empty_messages(params[:messagebox].to_sym => true)
      redirect_to messages_url(params[:messagebox]), :notice => "Successfully delete all messages."
   end
	end

	def token
    query = "%" + params[:q] + "%"
    recipients = User.select("id,email").where("email like ?", query)
    respond_to do |format|
      format.json { render :json => recipients.map { |u| { "id" => u.id, "name" => u.email} } }
    end
	end

private 

  def read_unread_messages(isRead, *messages)
    messages.each do |msg|
      unless msg.copies
        if isRead
          msg.mark_as_read unless msg.read?
        else
          msg.mark_as_unread if msg.read?
        end
      end
    end
  end

	def delete_messages(isDelete, *messages)
    messages.each do |msg|  
      if isDelete
        msg.delete  
      else
        msg.undelete  
      end 
    end
	end

end
