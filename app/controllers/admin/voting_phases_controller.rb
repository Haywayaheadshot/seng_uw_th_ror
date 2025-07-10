module Admin
  class VotingPhasesController < BaseController
    before_action :set_budget_cycle
    before_action :set_voting_phase, only: %i[show edit update destroy]

    def index
      @voting_phases = @budget_cycle.voting_phases.order(:start_date)
      respond_to do |format|
        format.html
        format.json { render json: @voting_phases.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility]) }
      end
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: @voting_phase.as_json(only: %i[id name phase_status start_date end_date voting_rules participant_eligibility]) }
      end
    end

    def new
      @voting_phase = @budget_cycle.voting_phases.build
      respond_to do |format|
        format.html
        format.json { render json: @voting_phase }
      end
    end

    def create
      @voting_phase = @budget_cycle.voting_phases.build(voting_phase_params)
      respond_to do |format|
        if @voting_phase.save
          format.html { redirect_to admin_budget_cycle_voting_phase_path(@budget_cycle, @voting_phase), notice: 'Voting phase created successfully.' }
          format.json { render json: @voting_phase, status: :created }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @voting_phase.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html
        format.json { render json: @voting_phase }
      end
    end

    def update
      respond_to do |format|
        if @voting_phase.update(voting_phase_params)
          format.html { redirect_to admin_budget_cycle_voting_phase_path(@budget_cycle, @voting_phase), notice: 'Voting phase updated successfully.' }
          format.json { render json: @voting_phase, status: :ok }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @voting_phase.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @voting_phase.destroy
      respond_to do |format|
        format.html { redirect_to admin_budget_cycle_voting_phases_path(@budget_cycle), notice: 'Voting phase deleted successfully.' }
        format.json { head :no_content }
      end
    end

    private

    def set_voting_phase
      @voting_phase = @budget_cycle.voting_phases.find(params[:id])
    end

    def voting_phase_params
      params.require(:voting_phase).permit(
        :name, :start_date, :end_date, :phase_status,
        voting_rules: [:max_votes],
        participant_eligibility: [:min_age]
      )
    end
  end
end
