defmodule MeetupApi.V3.Request do
  alias MeetupApi.V3.{Api, Request}

  defmodule Params do
    defstruct [:page, :offset, :fields, :only, :omit, :key, :access_token]
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

  def add_authentication(%Request{params: params} = request, nil) do
    new_params = %Params{params | key: Api.key, access_token: nil}
    %Request{request | params: new_params}
  end

  def add_authentication(%Request{params: params} = request, access_token) do
    new_params = %Params{params | access_token: access_token, key: nil}
    %Request{request | params: new_params}
  end
end
