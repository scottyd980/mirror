# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mirror.Repo.insert!(%Mirror.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Mirror.Repo.insert!(%Mirror.RetrospectiveType{name: "Sticky Notes"})
