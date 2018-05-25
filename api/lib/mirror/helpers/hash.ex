defmodule Mirror.Helpers.Hash do
  
    def generate_unique_id() do
      UUID.uuid4()
    end

    def generate_unique_id(_id, _unique_key) do
      UUID.uuid4()
    end
  
  end
  