require 'generators/fetty'

module Fetty
  module Generators
    class SetupGenerator < Base
      
      class_option :skip_required, :desc => 'Skip required plugin installation [meta_search, will_paginate, simple_form, jquery-rails]', :type => :boolean 
      class_option :skip_optional, :desc => 'Skip installation of authentication plugin (devise) & authorizations plugin (cancan)', :type => :boolean 
      
      def add_install_gems
      	#required
      	unless options.skip_optional?
	      	add_gem("meta_search")
			add_gem("will_paginate")
			
			add_gem("simple_form")
			generate("simple_form:install")
			
			add_gem("jquery-rails")
			generate("jquery:install")
      	end
      	
      	# optional
      	unless options.skip_optional?
      		install_devise
      		install_cancan
      		install_paperclip
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
       
    end
  end
end
