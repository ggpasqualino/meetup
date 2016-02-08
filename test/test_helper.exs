ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Meetup.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Meetup.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Meetup.Repo)

