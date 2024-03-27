defmodule UiWeb.GpsLive do
  use Phoenix.LiveView 
  
  def mount(_params, _session, socket) do 
    Phoenix.PubSub.subscribe(Ui.PubSub, "gps")
    {:ok, assign(socket, messages: [], current_message: nil)}
  end

  def handle_info({:new_message, message}, socket) do 
    case message do 
      << _head::binary-size(3), "RMC", _rest::binary >> -> 
        {
          :noreply,
          assign(
            socket,
            messages: [message | socket.assigns.messages],
            current_message: :binary.split(message, ",", [:global])
          )
        }
      _ -> {
        :noreply,
        assign(
          socket,
          messages: socket.assigns.messages,
          current_message: socket.assigns.current_message
        )
      }
    end
  end
  
  def lat_to_degrees(lat, _dir) when lat == "", do: "N/A"
  def lat_to_degrees(<< degrees::binary-size(2), seconds::binary >>, direction) do 
    { degrees, _ } = Float.parse(degrees)
    { seconds, _ } = Float.parse(seconds)
    (degrees + seconds / 60) * (if direction == "N", do: 1, else: -1)
  end 

  def long_to_degrees(long, _dir) when long == "", do: "N/A"
  def long_to_degrees(<< degrees::binary-size(3), seconds::binary >>, direction) do 
    { degrees, _ } = Float.parse(degrees)
    { seconds, _ } = Float.parse(seconds)
    (degrees + seconds / 60) * (if direction == "E", do: 1, else: -1)
  end 
  
  def knots_to_mph(knots) when knots == "", do: "N/A"
  def knots_to_mph(knots) do 
    { knots, _ } = Float.parse(knots)
    knots * 1.15078
  end
  
  def format_time(time) when time == "", do: "N/A"
  def format_time(<< hours::binary-size(2), minutes::binary-size(2), seconds::binary-size(2), _rest::binary >>) do 
    "#{hours}:#{minutes}:#{seconds}"
  end

  def render(assigns) do 
    ~H"""
      <div class="flex flex-col gap-y-4">
        <%= if @current_message do %>
          <h1>UTC Time: <%= format_time(Enum.at(@current_message, 1, "")) %></h1>
          <h1>Latitude: <%= lat_to_degrees(Enum.at(@current_message, 3, ""), Enum.at(@current_message, 4)) %> </h1>
          <h1>Longitude: <%= long_to_degrees(Enum.at(@current_message, 5, ""), Enum.at(@current_message, 6)) %> </h1>
          <h1>Speed: <%= knots_to_mph(Enum.at(@current_message, 7, "")) %> </h1>
          <%= inspect(@current_message) %>
        <% else %>
          <h1>Waiting for GPS data...</h1>
        <% end %>
      </div>
    """
  end
end
