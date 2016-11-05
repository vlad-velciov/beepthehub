defmodule Web.PageController do
  use Web.Web, :controller
  require Logger

  def index(conn, _params) do
    github_link = "https://github.com/login/oauth/authorize?client_id=e5d6e30f2bd1216195bd&state=1234&scope=write:repo_hook"

    access_token = get_session(conn, :access_token)
    Logger.info "access_token #{access_token}"

    repos = if access_token != nil do
      repos_response = HTTPotion.get("https://api.github.com/user/repos?access_token=#{access_token}", headers: ["User-Agent": "My App", "Accept": "application/json"])

      parsed_repos = Poison.Parser.parse!(repos_response.body)

      recursive_function(parsed_repos)
    else
      []
    end

    is_logged = access_token != nil && access_token != ""

    render conn, "index.html", is_logged: is_logged, repos: repos, github_link: github_link
  end

  def recursive_function(remaining) do
    if length(remaining) != 0 do
      rem = recursive_function(tl(remaining))
      [hd(remaining)["full_name"]] ++ rem
    else
      []
    end
  end

  def auth(conn, _params) do
    params = _params
    client_id = System.get_env("GITHUB_CLIENT_ID")
    client_secret = System.get_env("GITHUB_CLIENT_SECRET")

    body = "client_id=" <>
      URI.encode_www_form(client_id) <>
     "&client_secret=" <>
     URI.encode_www_form(client_secret) <>
     "&code=" <>
     URI.encode_www_form(params["code"])

    Logger.info "body that will be sent to github: #{body}"

    response = HTTPotion.post "https://github.com/login/oauth/access_token", [body: body, headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]

    parsed_response = URI.query_decoder(response.body) |> Enum.to_list()

    access_token = elem(hd(parsed_response), 1)

    Logger.info "access_token #{access_token}"

    conn = put_session(conn, :access_token, access_token)

    render(conn, "auth.html", params: _params)
  end
end
