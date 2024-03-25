defmodule Ui.Schema.Location do
  use Ecto.Schema

  # location is the DB table
  schema "location" do
    field :time,    :utc_datetime
    field :latitude, :float
    field :longitude, :float
    belongs_to :trip, Ui.Schema.Trip
  end
end
