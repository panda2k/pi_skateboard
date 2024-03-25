defmodule Ui.Schema.Trip do
  use Ecto.Schema

  # location is the DB table
  schema "trip" do
    has_many :locations, Ui.Schema.Location
  end
end
