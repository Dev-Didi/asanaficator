defmodule Asanaficator do
  use HTTPoison.Base 
  require Req
  defmodule Client do
    defstruct auth: nil, endpoint: "https://app.asana.com/api/1.0/"

    @type auth :: %{user: binary, password: binary} | %{access_token: binary}
    @type t :: %__MODULE__{auth: auth, endpoint: binary}

    @spec new() :: t
    def new(), do: %__MODULE__{}

    @spec new(auth) :: t
    def new(auth),  do: %__MODULE__{auth: auth}

    @spec new(auth, binary) :: t
    def new(auth, endpoint) do
      endpoint = if String.ends_with?(endpoint, "/") do
        endpoint
      else
        endpoint <> "/"
      end
      %__MODULE__{auth: auth, endpoint: endpoint}
    end
  end

  @user_agent [{"User-agent", "asanaficator"}]

  @type response :: {integer, any} | :jsx.json_term

@spec process_response(Req.Response.t) :: response
  def process_response(response) do  
    status_code = response.status
    headers = response.headers
    body = response.body
    response = unless body == "", do: Req.Response.json(response).body |> JSX.decode!,
    else: nil

    if (status_code == 200), do: response,
    else: {status_code, response}
  end


def cast(mod, resp, nest_fields \\ %{}) do
    {converted, unrecognized} =
      Enum.reduce(resp, {Map.new(), Map.new()}, fn {k, v}, {acc, unrecognized} ->
      k_atom = String.to_atom(k)
      case Map.has_key?(nest_fields, k_atom) do
        true ->
          {Map.put_new(acc, k_atom, cast(nest_fields[k_atom], v, nest_fields[k_atom].get_nest_fields())), unrecognized}
        false ->
          case Map.has_key?(Map.keys(mod.__struct__), k_atom) do
            true -> {Map.put_new(acc, k_atom, v), unrecognized}
            false -> {acc, Map.put_new(unrecognized, k_atom, v)}
          end
      end
    end)
    Kernel.struct(mod, Map.put_new(converted, :data, unrecognized))
  end

  def delete(client, path, body \\ "") do
    _request(:delete, url(client, path), client.auth, body)
  end

  def post(client, path, body \\ "") do
    _request(:post, url(client, path), client.auth, body)
  end

  def patch(client, path, body \\ "") do
    _request(:patch, url(client, path), client.auth, body)
  end

  def put(client, path, body \\ "") do
    _request(:put, url(client, path), client.auth, body)
  end

  def get(client, path, params \\ []) do
    url = url(client, path)
    url = <<url :: binary, build_qs(params) :: binary>>
    _request(:get, url, client.auth)
  end

  def _request(method, url, auth, body \\ nil) do
    json_request(method, url, body, authorization_header(auth, @user_agent))
  end

  def json_request(method, url, body \\ nil, headers \\ [], options \\ []) do
    IO.puts("URL: " <> url)
    {:ok, resp} = case method do
      :get -> Req.request(Req.new(method: method, url: url, headers: headers), options)
      _ -> Req.request(Req.new(method: method, body: body, url: url, headers: headers), options)
    end
    process_response(resp)
  end

  def raw_request(method, url, body \\ nil, headers \\ [], options \\ []) do
    request!(method, url, body, headers, options) |> process_response
  end

  @spec url(client :: Client.t, path :: binary) :: binary
  defp url(%Client{endpoint: endpoint}, path) do
    endpoint <> path
  end


  @spec build_qs([{atom, binary}]) :: binary
  defp build_qs([]), do: ""
  defp build_qs(kvs), do: to_string('?' ++ URI.encode_query(kvs))

  @doc """
  There are two ways to authenticate through GitHub API v3:

    * Basic authentication
    * OAuth2 Token

  This function accepts both.

  ## More info
  https://asana.com/developers/documentation/getting-started/authentication
  """
  @spec authorization_header(Client.auth, list) :: list
  def authorization_header(%{user: user, password: password}, headers) do
    userpass = "#{user}:#{password}"
    headers ++ [{"Authorization", "Basic #{:base64.encode(userpass)}"}]
  end

  def authorization_header(%{access_token: token}, headers) do
    token = Base.encode64(token <> ":")
    headers ++ [{"Authorization", "Basic #{token}"}]
  end

  def authorization_header(_, headers), do: headers

  @doc """
  Same as `authorization_header/2` but defaults initial headers to include `@user_agent`.
  """
  def authorization_header(options), do: authorization_header(options, @user_agent)
end
