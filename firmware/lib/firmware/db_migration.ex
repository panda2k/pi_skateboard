defmodule Firmware.DbMigration do 
  @app :ui
  def migrate() do 
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos() do
    _ = Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
