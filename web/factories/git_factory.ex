defmodule Web.GitFactory do
  require Logger
  def create(params) do

    # global have_message = false
    try do
      git = %{ message: "Git is stupid. #yolo", avatar_url: "yolo"}
      parsed_params = params
      git = if Map.has_key?(parsed_params, "deployment") do
        Web.GitFactory.Deployment.create(params)
      else
        if Map.has_key?(parsed_params, "release") do
         Web.GitFactory.Release.create(parsed_params)
        else
          if Map.has_key?(parsed_params, "head_commit") do
            Web.GitFactory.Push.create(parsed_params)
          else
            if Map.has_key?(parsed_params, "pull_request") do
              Web.GitFactory.PullRequest.create(parsed_params)
            end
          end
        end
      end
      Logger.info(inspect(git))
      git
    rescue
      e in BadMapError -> e
    end
    # Logger.info(have_message)
    # if have_message == false do
    #
    # else
    #   git
    # end
  end

  def repository_details(params) do
    repository_name = params["repository"]["name"]
  end

  defmodule Deployment do
    def create(params) do

      deployment = params["deployment"]
      creator_name = if Map.has_key?(deployment, "creator") && Map.has_key?(deployment["creator"], "login") do
        deployment["creator"]["login"]
      else
        "unknown user"
      end

      date = deployment["created_at"]
      # in case we need it
      action_url = deployment["url"]

      action = Web.GitFactory.repository_details(params)
      # action = String.capitalize(Web.GitFactory.repository_details(params))

      message = "#{String.capitalize(creator_name)} made a deploy on #{action} at #{date}."
      avatar_url = params["creator"]["avatar_url"]
      %{message: message, avatar_url: avatar_url}
    end
  end

  defmodule Release do
    def create(params) do
      release = params["release"]

      creator_name = if Map.has_key?(release, "author") && Map.has_key?(release["author"], "login") do
        release["author"]["login"]
      else
        "unknown user"
      end

      date = release["created_at"]

      # in case we need it
      action_url = release["url"]

      action = Web.GitFactory.repository_details(params)
      # action = String.capitalize(Web.GitFactory.repository_details(params))

      message = "#{String.capitalize(creator_name)} made a release on #{action} at #{date}."
      avatar_url = release["author"]["avatar_url"]
      x = %{message: message, avatar_url: avatar_url}
      IO.puts x
      x
    end
  end

  defmodule PullRequest do
    def create(params) do
      pull_request = params["pull_request"]
      creator_name = if Map.has_key?(pull_request, "user") && Map.has_key?(pull_request["user"], "login") do
        pull_request["user"]["login"]
      else
        "unknown user"
      end

      date = pull_request["created_at"]
      # in case we need it
      action_url = params["url"]

      commits_number = pull_request["commits"]
      title = pull_request["title"]
      action = Web.GitFactory.repository_details(params)

      message = "#{String.capitalize(creator_name)} made a pull request on #{action} at #{date} with the title: #{title}. \n Number of commits: #{commits_number}"
      avatar_url = pull_request["user"]["avatar_url"]

      %{message: message, avatar_url: avatar_url}
    end
  end

  defmodule Push do
    def create(params) do
      head_commit = params["head_commit"]
      creator_name = if Map.has_key?(head_commit, "author") && Map.has_key?(head_commit["author"], "name") do
        head_commit["author"]["name"]
      else
        "unknown user"
      end

      pr_message = head_commit["message"]

      date = params["timestamp"]

      action_url = head_commit["url"]
      action = Web.GitFactory.repository_details(params)

      message = "#{String.capitalize(creator_name)} made a push on #{action} at #{date}. \n Head commit message: #{pr_message}."
      avatar_url = head_commit["author"]["avatar_url"]

      %{message: message, avatar_url: avatar_url}
    end
  end
end
