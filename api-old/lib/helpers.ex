defmodule Mirror.Helpers do

    def atomic_map(string_keyed_map) do
        AtomicMap.convert(string_keyed_map, safe: false, underscore: true )
    end

end