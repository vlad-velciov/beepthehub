defmodule Web.APIController do
  use Web.Web, :controller
  require Logger

  # post for git webhook
  def git_hook(conn, _params) do
    params = _params
    Logger.info "Json from github: #{inspect(params)}"

    git_object = Web.GitFactory.create(params)
    Logger.info "=======================================params[payload][deployment]======================================================="
    Logger.info inspect(params["payload"]["deployment"])
    Logger.info "===============================================params[deployment]==============================================="
    Logger.info inspect(params["deployment"])
    Logger.info "=================================================params[payload]============================================="
    Logger.info inspect(params["payload"])

    Web.Endpoint.broadcast("room:lobby", "new_msg", %{"body" => git_object.message, "avatar" => git_object.avatar_url})

    conn
    |> put_status(:created)
    |> json(params)
  end
end
