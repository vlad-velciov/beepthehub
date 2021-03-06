defmodule Web.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    IO.puts "in join room:lobby"
    # IO.puts _message
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    IO.puts "in join room:"
    # IO.puts _message
    {:error, %{reason: "unauthorized"}}
  end


  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
