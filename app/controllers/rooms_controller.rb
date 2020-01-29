class RoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @rooms = Room.order(:id)
  end

  def show
    @room = Room.find(params[:id])
    @messages = @room.messages
  end
end
