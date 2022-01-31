defmodule DaneordleWeb.MainLive do
  use DaneordleWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= for {key, val} <- @keyboard.consonants do %>
      <button data-key={key} data-status={val} class="tile"><%= key %></button>
    <% end %>

    <%= for {key, val} <- @keyboard.vowels do %>
      <button data-key={key} data-status={val} class="tile"><%= key %></button>
    <% end %>

    <%= for {key, val} <- @keyboard.complex_codas do %>
      <button data-key={key} data-status={val} class="tile"><%= key %></button>
    <% end %>

    <%= for {key, val} <- @keyboard.functions do %>
      <button data-key={key} data-status={val} class="tile"><%= key %></button>
    <% end %>
    """
  end

  def mount(_params, _stuff, socket) do
    {:ok, assign(socket, :keyboard, %Daneordle.Keyboard{})}
  end
end
