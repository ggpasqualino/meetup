defmodule MeetupApi.V3.Request do
  alias MeetupApi.V3.Request

  defmodule Params do
    defstruct [:page, :offset, :fields, :only, :omit, :access_token]
  end

  defstruct [:path, :user, :params]

  def new(path, user) do
    %Request{path: path, user: user, params: %Params{}}
  end

  def add_page(%Request{params: params} = request, page) do
    new_params = %Params{params | page: page}
    %Request{request | params: new_params}
  end

  def add_offset(%Request{params: params} = request, offset) do
    new_params = %Params{params | offset: offset}
    %Request{request | params: new_params}
  end

  def add_fields(%Request{params: params} = request, fields) do
    new_params = %Params{params | fields: fields}
    %Request{request | params: new_params}
  end

  def add_only(%Request{params: params} = request, only) do
    new_params = %Params{params | only: only}
    %Request{request | params: new_params}
  end

  def add_omit(%Request{params: params} = request, omit) do
    new_params = %Params{params | omit: omit}
    %Request{request | params: new_params}
  end

  def add_authentication(%Request{params: params} = request, access_token) do
    new_params = %Params{params | access_token: access_token}
    %Request{request | params: new_params}
  end

  def parse(nil), do: nil
  def parse(url) when is_binary(url) do
    with uri <- URI.parse(url),
         params <- URI.decode_query(uri.query),
           path <- uri.path,
           user <- (params["access_token"] || params["key"]) do
      path
      |> new(user)
      |> add_page(params["page"])
      |> add_offset(params["offset"])
      |> add_fields(params["fields"])
      |> add_only(params["only"])
      |> add_omit(params["omit"])
      |> add_authentication(params["access_token"])
    end
  end
end
