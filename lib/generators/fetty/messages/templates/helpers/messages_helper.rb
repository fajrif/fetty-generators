module MessagesHelper

  module Model
      module UserInstanceMethods

        def send_message?(options)
          send_message(options)
          true                        
        rescue Exception => e
          false
        end 

        def send_message(options)
          unless options[:recipients].nil?
            transaction do
              recipients = options[:recipients]
              options.delete(:recipients)

              options[:subject_id] = Message.sequence_subject_id if options[:subject_id].nil?

              recipients.each do |rec|
                # => create message copies
                options[:user_id] = self.id
                options[:sender_id] = self.id
                options[:recipient_id] = rec.id
                options[:copies] = true
                Message.create(options)
                # => create message
                options[:user_id] = rec.id 
                options[:sender_id] = self.id
                options[:recipient_id] = rec.id
                options[:copies] = false
                options[:parent_id] = Message.next_parent_id(options[:parent_id]) unless options[:parent_id].nil?
                Message.create(options)
              end
            end
          else
            raise "Required recipients"
          end
        rescue Exception => e
          raise e 
        end
        
        def inbox(options = {})
          options[:deleted] = false
          options[:copies] = false
          self.messages.where(options)
        end

        def outbox(options = {})
          options[:deleted] = false
          options[:copies] = true
          self.messages.where(options)
        end

        def trash(options = {})
          options[:deleted] = true
          self.messages.where(options)
        end

        def empty_messages(options = {})
          if options.empty? or options[:inbox] or options[:outbox]
            self.inbox.update_all(:deleted => true)
            self.outbox.update_all(:deleted => true)
          elsif options[:trash]
            self.trash.delete_all
          end
        end

      end

  end
end
