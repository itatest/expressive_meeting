module Api
  module V1
    class ApiController < ActionController::Base
      respond_to :json
      
      private

      def render_created(model)
        render json: model, status: :created
      end

      def render_accepted
        render :json => {:errors => nil}.to_json, :status => 202
      end

      def render_not_destroyed(model)
        render :json => {:errors => model.errors.messages[:base][0]}.to_json, :status => 422
      end
      
      def render_not_found(target)
        render :json => {:errors => target + " not found."}.to_json, :status => 404
      end

      def render_forbidden(e)
        render :json => {:errors => e.message}.to_json, :status => 403
      end

      def render_invalid(e)
        render :json => {:errors => e.message}.to_json, :status => 422
      end

      def render_exception(e)
        Rails.logger.error(e)
        render :json => {:errors => e.message}.to_json, :status => 500
      end
    end
  end
end
