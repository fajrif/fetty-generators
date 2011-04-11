require 'generators/fetty'

module Fetty
  module Generators
    class SetupGenerator < Base
     
      class_option :required, :desc => 'Only install required gems [meta_search, will_paginate, simple_form, jquery-rails]', :type => :boolean, :default => true 
      class_option :optional, :desc => 'Only install optional gems such as [devise, cancan, paperclip, tiny_mce]', :type => :boolean, :default => true 
      
      def add_install_gems
      	 	
      	#required
      	if options.required?
      		add_gem("meta_where")
	      	add_gem("meta_search")
			add_gem("kaminari")
			
			add_gem("simple_form")
			generate("simple_form:install")
			
			add_gem("jquery-rails")
			generate("jquery:install")
      	end
      	
      	# optional
      	if options.optional?
      		install_devise
      		install_cancan
      		install_paperclip
      		install_tiny_mce
  		end
      end

private
      
      def install_devise
  		opt = ask("Would you like to install Devise for authentication? [yes]")
      	if opt == "yes" || opt.blank?
      		add_gem("devise")
      		generate("devise:install")
      		model_name = ask("Would you like the user model to be called? [user]")
	  		model_name = "user" if model_name.blank?
	  		generate("devise", model_name)
	  		opt = ask("Would you like to set global authentications in application_controller.rb? [yes]")
	  		if opt == "yes" || opt.blank?
  				inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
				  "\n   before_filter :authenticate_user!"
				end
	  		end
  		end
      end
      
      def install_cancan
  		opt = ask("Would you like to install CanCan for authorization? [yes]")
      	if opt == "yes" || opt.blank?
      		add_gem("cancan","~> 1.5.0")
			copy_file 'ability.rb', 'app/models/ability.rb'
			inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
			  "\n   rescue_from CanCan::AccessDenied do |exception| flash[:alert] = exception.message; redirect_to root_url end;"
			end
  		end
      end
      
      def install_paperclip
  		opt = ask("Would you like to install Paperclip for handling your attachment? [yes]")
      	if opt == "yes" || opt.blank?
      		add_gem("paperclip")
  		end
      end
      
      def install_tiny_mce
  		opt = ask("Would you like to install Tiny-MCE Editor? [yes]")
      	if opt == "yes" || opt.blank?
      		add_gem("tiny_mce")
  		end
      end
       
    end
  end
end
