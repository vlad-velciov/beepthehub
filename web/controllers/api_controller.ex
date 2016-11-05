defmodule Web.APIController do
  use Web.Web, :controller
  require Logger

  # post for git webhook
  def git_hook(conn, _params) do
    params = _params
    Logger.info "Json from github: #{inspect(params)}"

    if Map.has_key?(params, "deployment") do

      creator_name = if Map.has_key?(params["deployment"], "creator") && Map.has_key?(params, "login") do
        params["deployment"]["creator"]["login"]
      else
        "unknown user"
      end

      aplication_name = if Map.has_key?(params["deployment"], "environment") do
        params["deployment"]["environment"]
      else
        "unknown app"
      end

      task = if Map.has_key?(params["deployment"], "task") do
        params["deployment"]["task"]
      else
        "unknown task"
      end

      message = "#{String.capitalize(creator_name)} made a #{task} on #{String.capitalize(aplication_name)}"
      Web.Endpoint.broadcast("room:lobby", "new_msg", %{"body" => message})
    end

    conn
    |> put_status(:created)
    |> json(params)
  end
end
