%%%
%%% Copyright 2013, Rodolphe Quiedeville <rodolphe@quiedeville.org>
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%

%%% ====================================================================
%%% file : bear_test.erl
%%% @author : Rodolphe Quiedeville <rodolphe@quiedeville.org>
%%% @doc
%%% Unit test for functions defined in bear.erl
%%% @end
%%% ====================================================================
-module(bear_test).

-compile(export_all).

-record(scan_result, {n=0, sumX=0, sumXX=0, sumInv=0, sumLog, max, min}).
-record(scan_result2, {x2=0, x3=0, x4=0}).

-include_lib("eunit/include/eunit.hrl").

-define(PRECISION, 1.0e15).

get_statistics_1_empty_test() ->
    %% get_statistics/1
    %% Empty set of values
    Percentile = [{50, 0.0},{75, 0.0},{90, 0.0},{95, 0.0},{99, 0.0},{999, 0.0}],
    Stats = bear:get_statistics([]),
    ?assertEqual({min, 0.0}, lists:keyfind(min, 1, Stats)),
    ?assertEqual({max, 0.0}, lists:keyfind(max, 1, Stats)),
    ?assertEqual({arithmetic_mean, 0.0}, lists:keyfind(arithmetic_mean, 1, Stats)),
    ?assertEqual({geometric_mean, 0.0}, lists:keyfind(geometric_mean, 1, Stats)),
    ?assertEqual({harmonic_mean, 0.0}, lists:keyfind(harmonic_mean, 1, Stats)),
    ?assertEqual({median, 0.0}, lists:keyfind(median, 1, Stats)),
    ?assertEqual({variance, 0.0}, lists:keyfind(variance, 1, Stats)),
    ?assertEqual({standard_deviation, 0.0}, lists:keyfind(standard_deviation, 1, Stats)),
    ?assertEqual({skewness, 0.0}, lists:keyfind(skewness, 1, Stats)),
    ?assertEqual({kurtosis, 0.0}, lists:keyfind(kurtosis, 1, Stats)),
    ?assertEqual({percentile, Percentile}, lists:keyfind(percentile, 1, Stats)),
    ?assertEqual({histogram, [{0,0}]}, lists:keyfind(histogram, 1, Stats)),
    ?assertEqual({n, 0}, lists:keyfind(n, 1, Stats)).

get_statistics_1_regular_test() ->
    %% get_statistics/1
    %% Non empty set of values
    Percentile = [{50, 5},{75, 8},{90, 9},{95, 10},{99, 10},{999, 10}],
    Stats = bear:get_statistics(lists:seq(1,10)),

    {geometric_mean, Geometric} = lists:keyfind(geometric_mean, 1, Stats),
    {harmonic_mean, Harmonic} = lists:keyfind(harmonic_mean, 1, Stats),
    {variance, Variance} = lists:keyfind(variance, 1, Stats),
    {standard_deviation, StandardDeviation} = lists:keyfind(standard_deviation, 1, Stats),
    {kurtosis, Kurtosis} = lists:keyfind(kurtosis, 1, Stats),

    ?assertEqual({min, 1}, lists:keyfind(min, 1, Stats)),
    ?assertEqual({max, 10}, lists:keyfind(max, 1, Stats)),
    ?assertEqual({arithmetic_mean, 5.5}, lists:keyfind(arithmetic_mean, 1, Stats)),
    ?assertEqual(4528728688116766, erlang:trunc(?PRECISION * Geometric)),
    ?assertEqual(3414171521474055, erlang:trunc(?PRECISION * Harmonic)),
    ?assertEqual({median, 5}, lists:keyfind(median, 1, Stats)),
    ?assertEqual(9166666666666666, erlang:trunc(?PRECISION * Variance)),
    ?assertEqual(3027650354097491, erlang:trunc(?PRECISION * StandardDeviation)),
    ?assertEqual({skewness, 0.0}, lists:keyfind(skewness, 1, Stats)),
    ?assertEqual(-1561636363636363, erlang:trunc(?PRECISION * Kurtosis)),
    ?assertEqual({percentile, Percentile}, lists:keyfind(percentile, 1, Stats)),
    ?assertEqual({histogram, [{6,6},{11,4},{16,0}]}, lists:keyfind(histogram, 1, Stats)),
    ?assertEqual({n, 10}, lists:keyfind(n, 1, Stats)).

get_statistics_2_1_test() ->
    %% get_statistics/2
    %% First set of values is empty
    Stats = bear:get_statistics(lists:seq(1,10), []),
    ?assertEqual(0.0, Stats).

get_statistics_3_test() ->
    %% get_statistics/2
    %% Second set of values is empty
    Stats = bear:get_statistics([], lists:seq(1,10)),
    ?assertEqual(0.0, Stats).

get_statistics_4_test() ->
    %% get_statistics/2
    %% Two set of values with different sizes
    Stats = bear:get_statistics(lists:seq(1,10),lists:seq(1,20)),
    ?assertEqual(0.0, Stats).

get_statistics_5_test() ->
    %% get_statistics/2
    %% Two set of values are valid
    Stats = bear:get_statistics(lists:seq(0,10),lists:seq(4,24,2)),
    ?assertEqual({covariance, 20.0}, lists:keyfind(covariance, 1, Stats)),
    ?assertEqual({tau, 1.0}, lists:keyfind(tau, 1, Stats)),
    ?assertEqual({rho, 1.0}, lists:keyfind(rho, 1, Stats)),
    ?assertEqual({r, 1.0}, lists:keyfind(r, 1, Stats)).

scan_values_test() ->
    ?assertEqual(#scan_result{n=8}, bear:scan_values([], #scan_result{n=8})),
    ?assertEqual(#scan_result{n=1,sumX=1,sumXX=1,sumInv=1.0,sumLog=0.0,max=1,min=1}, bear:scan_values([1])),
    ?assertEqual(#scan_result{n=4,sumX=10,sumXX=30,sumInv=2.083333333333333,sumLog=3.1780538303479453,max=4,min=1},
                 bear:scan_values([1,3,2,4])).

scan_values2_test() ->
    ?assertEqual(#scan_result{n=8}, bear:scan_values2([], 3, #scan_result{n=8})),
    ?assertEqual(#scan_result2{x2=6.6875,x3=-13.359375,x4=28.07421875}, bear:scan_values2([4,3,5], #scan_result{n=8,sumX=42})).

revsort_test() ->
    ?assertEqual([], bear:revsort([])),
    ?assertEqual([4,3,2], bear:revsort([3,2,4])).

arithmetic_mean_test() ->
    ?assertEqual(10.0, bear:arithmetic_mean(#scan_result{n=4, sumX=40})).

geometric_mean_test() ->
    ?assertEqual(25.790339917193062, bear:geometric_mean(#scan_result{n=4, sumLog=13})).

harmonic_mean_test() ->
    ?assertEqual(0, bear:harmonic_mean(#scan_result{n=100, sumInv=0})),
    ?assertEqual(10.0, bear:harmonic_mean(#scan_result{n=100, sumInv=10})).

percentile_test() ->
    ?assertEqual(3, bear:percentile([1,2,3,4,5], #scan_result{n=5},0.5)),
    ?assertEqual(5, bear:percentile([1,2,3,4,5], #scan_result{n=5},0.95)).

variance_test() ->
    ?assertEqual(7.0, bear:variance(#scan_result{n=7},#scan_result2{x2=42})).

std_deviation_test() ->
    ?assertEqual(3.0, bear:std_deviation(#scan_result{n=10},#scan_result2{x2=81})).

skewness_test() ->
    ?assertEqual(0.0, bear:skewness(#scan_result{n=10},#scan_result2{x2=0,x3=81})),
    ?assertEqual(3.0, bear:skewness(#scan_result{n=10},#scan_result2{x2=81,x3=810})).

kurtosis_test() ->
    ?assertEqual(0.0, bear:kurtosis(#scan_result{n=10},#scan_result2{x2=0,x4=81})),
    ?assertEqual(-2.0, bear:kurtosis(#scan_result{n=10},#scan_result2{x2=81,x4=810})).

update_bin_1_test() ->
    %% with empty dict
    Dict = dict:new(),
    C = bear:update_bin(4, [4], Dict),
    ?assertEqual(1, dict:fetch(4, C)).

get_covariance_test() ->
    %% Array 1 is too short
    ?assertEqual(0.0, bear:get_covariance([], [2,1,2,3,4,5,6])),
    %% Array 2 is too short
    ?assertEqual(0.0, bear:get_covariance([1,2,3,4,5,6], [])),
    %% diffenrent arry length
    ?assertEqual(0.0, bear:get_covariance([1,2,3,4,5,6], [1,2,3,4,5,6,7])),
    %% Usual case
    ?assertEqual(-30944444444444444, erlang:trunc(?PRECISION * bear:get_covariance([11,2,3,41,5,9], [34,2,23,4,5,6]))).

ranks_of_test() ->
    ?assertEqual([4.0,3.0,1.0,2.0], bear:ranks_of([3,4,15,6])).

get_pearson_correlation_test() ->
    ?assertEqual(0.0, bear:get_pearson_correlation([], 42)),
    ?assertEqual(0.0, bear:get_pearson_correlation(42, [])),
    ?assertEqual(0.0, bear:get_pearson_correlation(lists:seq(1,10), lists:seq(1,11))),
    ?assertEqual(1.0, bear:get_pearson_correlation(lists:seq(1,10), lists:seq(1,10))),
    ?assertEqual(1.0, bear:get_pearson_correlation(lists:seq(0,10), lists:seq(5,15))),
    ?assertEqual(1.0, bear:get_pearson_correlation(lists:seq(40,60,2), lists:seq(10,20))).

get_pearson_correlation_nullresult_test() ->
    %% The two series do not correlate
    A = [-1,-0.5,0,0.5,1],
    B = [1,0.25,0,0.25,1],
    ?assertEqual(0.0, bear:get_pearson_correlation(A, B)).

round_bin_test() ->
    ?assertEqual(10, bear:round_bin(10)),
    ?assertEqual(10, bear:round_bin(10, 5)),
    ?assertEqual(42, bear:round_bin(15, 42)),
    ?assertEqual(45, bear:round_bin(42, 15)).

get_bin_width_test() ->
    ?assertEqual(1, bear:get_bin_width(0, 10)),
    ?assertEqual(22, bear:get_bin_width(10.0, 4.0)).

get_bin_count_test() ->
    ?assertEqual(3, bear:get_bin_count(9, 15, 3)),
    ?assertEqual(4, bear:get_bin_count(10.2, 20.2, 4)).

get_kendall_correlation_test()->
    ?assertEqual(0.0, bear:get_kendall_correlation([], [])),
    ?assertEqual(0.0, bear:get_kendall_correlation([], [1,2,3,4,5,6,7])),
    ?assertEqual(0.0, bear:get_kendall_correlation([1,2,3,4,5,6,7],[])),
    ?assertEqual(0.0, bear:get_kendall_correlation(lists:seq(1,10),lists:seq(1,11))),
    ?assertEqual(1.0, bear:get_kendall_correlation([1,2,3,4,5,6,7], [2,3,4,5,6,7,9])).

get_spearman_correlation_test()->
    ?assertEqual(0.0, bear:get_spearman_correlation([], [])),
    ?assertEqual(0.0, bear:get_spearman_correlation([], [1,2,3,4,5,6,7])),
    ?assertEqual(0.0, bear:get_spearman_correlation([1,2,3,4,5,6,7],[])),
    ?assertEqual(0.0, bear:get_spearman_correlation(lists:seq(1,10),lists:seq(1,11))),
    ?assertEqual(1.0, bear:get_spearman_correlation([1,2,3,4,5,6,7], [2,3,4,5,6,7,9])).


math_log_test() ->
    ?assertEqual(1, bear:math_log(0)),
    ?assertEqual(1.0, bear:math_log(0.0)),
    ?assertEqual(3737669618283368, erlang:trunc(?PRECISION * bear:math_log(42))).

inverse_test() ->
    ?assertEqual(0, bear:inverse(0)),
    ?assertEqual(0.0, bear:inverse(0.0)),
    ?assertEqual(0.5, bear:inverse(2)).

get_hist_bins_test() ->
    ?assertEqual([4], bear:get_hist_bins(1, 4, 5, 10)).

tied_ordered_ranking_test() ->
    ?assertEqual([3,2,1], bear:tied_ordered_ranking([], [], [1,2,3])).

kendall_right_off_test() ->
    %% empty array
    ?assertEqual("654321", bear:kendall_right_of([],"123456")).

tied_add_prev_test() ->
    ?assertEqual([{2.5,5},{2.5,5},{2.5,5},{2.5,5},{2,3}], bear:tied_add_prev([{2, 3}], {[1,2,3,4], 5})).

tied_rank_worker_test() ->
    ?assertEqual([{2.0,5},{2.0,5},{2.0,5},{2.0,5}], bear:tied_rank_worker([], [{2.0,5}], {[1,2,3], 5})),
    ?assertEqual([{2.0,5},{2.0,5},{2.0,5},{2.0,5},{2.0,5},{2.0,5}],
                 bear:tied_rank_worker([{2.0,5},{2.0,5}], [{2.0,5}], {[1,2,3], 5})).

subset_test() ->
    Stats = bear:get_statistics(bear:test_values()),
    match_values(Stats).

full_subset_test() ->
    Stats = bear:get_statistics(bear:test_values()),
    match_values2(Stats).

negative_test() ->
    %% make sure things don't blow up with a negative value
    Values = [1,-1,-2,3,3,4,5,6,7],
    [{min, -2}] = bear:get_statistics_subset(Values, [min]).

negative2_test() ->
    %% make sure things don't blow up with a negative value
    Values = [-1,-1,-2,-2,-3,-5,-6,-10],
    [{min, -10}] = bear:get_statistics_subset(Values, [min]).

match_values([H|T]) ->
    Res = bear:get_statistics_subset(bear:test_values(), [mk_item(H)]),
    Res = [H],
    match_values(T);
match_values([]) ->
    ok.

mk_item({percentile, Ps}) ->
    {percentile, [P || {P,_} <- Ps]};
mk_item({K, _}) ->
    K.

match_values2(Stats) ->
    Items = [mk_item(I) || I <- Stats],
    Stats = bear:get_statistics_subset(bear:test_values(), Items),
    ok.
