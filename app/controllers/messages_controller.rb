class MessagesController < ApplicationController
  before_action :set_match

  def create
    @message = @match.messages.build(message_params.merge(sender: current_user))

    if @message.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("chat-form", partial: "messages/form", locals: { match: @match, message: @match.messages.build }) }
        format.html { redirect_to match_path(@match) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("chat-form", partial: "messages/form", locals: { match: @match, message: @message }) }
        format.html { redirect_to match_path(@match), alert: @message.errors.full_messages.first }
      end
    end
  end

  private
    def set_match
      @match = current_user.matches.active.find(params[:match_id])
    end

    def message_params
      params.require(:message).permit(:body)
    end
end
