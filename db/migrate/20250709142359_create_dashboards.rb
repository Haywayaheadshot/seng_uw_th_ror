class CreateDashboards < ActiveRecord::Migration[8.0]
  def change
    create_table :dashboards, &:timestamps
  end
end
