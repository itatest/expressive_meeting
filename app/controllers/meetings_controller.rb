class MeetingsController < ApplicationController

  def index
    @meetings = Meeting.all
  end
  
  def show
    
  end
  
  def new
    @meeting = Meeting.new
  end
  
  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.master_user_id = @current_user.id
    if @meeting.save
      flash[:notice] = I18n.t('controller.meetings.created')
      redirect_to :action => "index"
    else
      flash[:alert] = I18n.t('controller.meetings.not_created')
      render "new"
    end
  end
  
  private
  
  def meeting_params
    params.require(:meeting).permit(:name, :description)
  end
end