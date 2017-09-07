class CreateGithubRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :github_records do |t|

      t.timestamps
    end
  end
end
