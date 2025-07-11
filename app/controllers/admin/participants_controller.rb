module Admin
  class ParticipantsController < BaseController
    before_action :set_participant, only: %i[show edit update destroy]

    def index
      @participants = Participant.all
    end

    def show; end

    def new
      @participant = Participant.new
    end

    def create
      @participant = Participant.new(participant_params)
      if @participant.save
        redirect_to admin_participants_path, notice: 'Participant created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @participant.update(participant_params)
        redirect_to admin_participants_path, notice: 'Participant updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @participant.destroy
      redirect_to admin_participants_path, notice: 'Participant deleted successfully.'
    end

    private

    def set_participant
      @participant = Participant.find(params[:id])
    end

    def participant_params
      params.require(:participant).permit(:name, :age)
    end
  end
end
