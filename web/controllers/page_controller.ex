defmodule Web.PageController do
  use Web.Web, :controller
  require Logger

  def index(conn, _params) do
    github_link = "https://github.com/login/oauth/authorize?client_id=#{System.get_env("GITHUB_CLIENT_ID")}&state=1234&scope=write:repo_hook"

    access_token = get_session(conn, :access_token)

    is_logged = access_token != nil && access_token != ""

    if is_logged do
      redirect conn, to: "/repo_selection"
    else
      render conn, "index.html", is_logged: is_logged, github_link: github_link
    end
  end

  def repo_selection(conn, _params) do
    access_token = get_session(conn, :access_token)

    repos = if access_token != nil do
      repos_response = HTTPotion.get("https://api.github.com/user/repos?access_token=#{access_token}", headers: ["User-Agent": "My App", "Accept": "application/json"])

      parsed_repos = Poison.Parser.parse!(repos_response.body)

      recursive_function(parsed_repos)
    else
      []
    end

    render(conn, "repo_selection.html", repos: repos)
  end

  def listen_to_repo(conn, _params) do
    access_token = get_session(conn, :access_token)
    # create webhook here
    #
    repo = _params["full_name"]
    body = Poison.encode!(%{"name": "web", "active": true, "config": %{"content_type": "json", "url": "https://beepthehub.herokuapp.com/hookmeup"}})
    response = HTTPotion.post "https://api.github.com/repos/#{repo}/hooks?access_token=#{access_token}", [body: body, headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"]]
    Logger.info "response from creating the hook: #{response.body}"
    # create webhook here
    render(conn, "listen_to_repo.html", params: _params)
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

    # Logger.info "body that will be sent to github: #{body}"

    response = HTTPotion.post "https://github.com/login/oauth/access_token", [body: body, headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]

    parsed_response = URI.query_decoder(response.body) |> Enum.to_list()

    access_token = elem(hd(parsed_response), 1)

    # Logger.info "access_token #{access_token}"

    conn = put_session(conn, :access_token, access_token)

    redirect conn, to: "/repo_selection"
  end
end
