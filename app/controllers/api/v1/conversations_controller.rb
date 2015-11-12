module Api
  module V1
    class ConversationsController < ApiController

      respond_to :json
      
      def index
        @conversations = Conversation.all
        render_created(@conversations)
      end

      def create
        @conversation = Conversation.create!(conversation_params(params))
        render_created(@conversation)
      end
      
      private
      
      def conversation_params(params)
        {
          "meeting_id" => params[:meeting_id],
          "message" =>  params[:message], 
          "user_id" =>  params[:user_id],
          "expression_id" => params[:expression_id],
          "datetime" => params[:datetime]
        }
      end
    end
  end
end
