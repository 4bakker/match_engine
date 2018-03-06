defmodule MatchEngine.ScoringTests do
  use ExUnit.Case

  @data "test/fixture/regio.json" |> File.read!() |> Poison.decode!()

  import MatchEngine

  test "score_all" do
    docs = @data["value"]

    result = docs
    |> score_all([title: "Amsterdam"])
    |> Enum.slice(0..1)

    assert [%{_match: %{score: 1}}, %{_match: %{score: 0}}] = result
  end

  test "filter_all" do
    docs = @data["value"]

    assert [m] = filter_all(docs, [title: "Amsterdam", key: "GM0363    "])
    assert 1 == m._match.score
  end

  test "score_all (map)" do
    docs = @data["value"]

    result = docs
    |> score_all(%{"title" => %{"_eq" => "Amsterdam"}})
    |> Enum.slice(0..1)

    assert [%{_match: %{score: 1}}, %{_match: %{score: 0}}] = result
  end

  test "score_all geo w/ maps" do
	  docs = [%{"city" => "amsterdam",
              "location" => %{"lat" => 52.363711, "lon" => 4.882609}},
            %{"city" => "new york",
              "location" => %{"lat" => 40.690902, "lon" => -73.922038}}]
    q = %{"location" => %{"_geo" => %{"lat" => 52.3303715, "lon" => 4.8813892}}}

    first =
      docs
      |> score_all(q)
      |> hd()

    assert first[:_match].score > 0
    assert first[:_match].distance > 0
  end

end
