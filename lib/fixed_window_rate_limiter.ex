defmodule FixedWindowRateLimiter do
  @moduledoc """
  A simple fixed window rate limiter.
  """

  @ets_table :fixed_window_table
  @default_limit 5
  @default_window 60

  def start do
    :ets.new(@ets_table, [:set, :public, :named_table])
    IO.puts("Fixed Window Rate Limiter started.")
  end

  def check_request(user_id, limit \\ @default_limit, window \\ @default_window) do
    now = :os.system_time(:second)
    current_window = div(now, window)

    case :ets.lookup(@ets_table, {user_id, current_window}) do
      [] ->
        :ets.insert(@ets_table, {{user_id, current_window}, 1})
        {:ok, "200 Request allowed"}

      [{{^user_id, ^current_window}, count}] when count < limit ->
        :ets.update_element(@ets_table, {user_id, current_window}, {2, count + 1})
        {:ok, "200 Request allowed"}

      _ ->
        {:error, "429 Too Many Requests"}
    end
  end
end

# Example Tests:
# FixedWindowRateLimiter.start()
# IO.inspect(FixedWindowRateLimiter.check_request("user1")) # {:ok, "200 Request allowed"}
# IO.inspect(FixedWindowRateLimiter.check_request("user1")) # {:ok, "200 Request allowed"}
# Enum.each(1..6, fn _ -> IO.inspect(FixedWindowRateLimiter.check_request("user1")) end)
