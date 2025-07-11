module Admin
  class VotingPhasesController < BaseController
    before_action :set_budget_cycle
    before_action :set_voting_phase, only: %i[show edit update destroy]

    def index
      @voting_phases = @budget_cycle.voting_phases.order(:start_date)
    end

    def show; end

    def new
      @voting_phase = @budget_cycle.voting_phases.build
    end

    def create
      @voting_phase = @budget_cycle.voting_phases.build(voting_phase_params)
      if @voting_phase.save
        redirect_to admin_budget_cycle_voting_phases_path(@budget_cycle), notice: 'Voting phase created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @voting_phase.update(voting_phase_params)
        redirect_to admin_budget_cycle_voting_phases_path(@budget_cycle), notice: 'Voting phase updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @voting_phase.destroy
      redirect_to admin_budget_cycle_voting_phases_path(@budget_cycle), notice: 'Voting phase deleted successfully.'
    end

    private

    def set_budget_cycle
      @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    end

    def set_voting_phase
      @voting_phase = @budget_cycle.voting_phases.find(params[:id])
    end

    def voting_phase_params
      params.require(:voting_phase).permit(:name, :start_date, :end_date, :phase_status, voting_rules: [:max_votes], participant_eligibility: [:min_age])
    end

    def phase_status_options
      VotingPhase.phase_statuses.keys.map { |status| [status.humanize, status] }
    end
  end
end
