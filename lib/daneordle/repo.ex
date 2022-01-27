defmodule Daneordle.Repo do
  use Ecto.Repo,
    otp_app: :daneordle,
    adapter: Ecto.Adapters.Postgres
end
