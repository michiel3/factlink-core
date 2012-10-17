class ConversationsController < ApplicationController
  def show
    respond_to do |format|
      format.html { render_backbone_page }
      format.json do
        @conversation = Queries::ConversationGet.execute(params[:id])
        @messages     = Queries::MessagesForConversation.execute(@conversation.id) if @conversation
        if @conversation and @messages.length > 0
          render 'conversations/show'
        else
          render json: [], status: :not_found
        end
      end
    end
  end

  def create
    CreateConversationWithMessageInteractor.perform(params[:recipients], params[:sender], params[:content])
    render json: {}
  end
end
