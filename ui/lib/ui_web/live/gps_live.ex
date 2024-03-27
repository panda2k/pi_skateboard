defmodule UiWeb.GpsLive do
  use Phoenix.LiveView 
  
  def mount(_params, _session, socket) do 
    Phoenix.PubSub.subscribe(Ui.PubSub, "gps")
    {:ok, assign(socket, messages: [])}
  end

  def handle_info({:new_message, message}, socket) do 
    {:noreply, assign(socket, messages: [message | socket.assigns.messages])}
  end

  def render(assigns) do 
    ~H"""
      <div class="flex flex-col gap-y-4">
        <%= for message <- @messages do %>
          <div><%= message %></div>
        <% end %>
      </div>
    """
  end
end
