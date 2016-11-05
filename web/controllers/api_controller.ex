defmodule Web.APIController do
  use Web.Web, :controller
  require Logger

  # post for git webhook
  def git_hook(conn, _params) do
    params = _params
    Logger.info "Json from github: #{inspect(params)}"
    Logger.debug "#{inspect(params)}"
    Logger.info "#{inspect(params)}"
    conn
    |> put_status(:created)
    |> json(params)
  end
end
