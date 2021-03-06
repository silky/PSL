theory Format_Result
  imports "PSL.PSL"
begin

ML_file  "../../../LiFtEr/Matrix_sig.ML"
ML_file  "../../../LiFtEr/Matrix_Struct.ML"

ML\<open>
val path = File.platform_path (Resources.master_directory @{theory}) ^ "/POPL2020_Semantic_Induct.csv";
val get_lines = split_lines o TextIO.inputAll o TextIO.openIn;

type datapoint =
 {file_name                       :string,
  numb_of_candidates_after_step_1 : int,
  numb_of_candidates_after_step_2 : int,
  numb_of_candidates_after_step_3 : int,
  numb_of_candidates_after_step_4 : int,
  numb_of_candidates_after_step_5 : int,
  line_number                     : int,
  rank                            : int option,
  score                           : int,
  execution_time                  : int(*,
  arbitrary                       : bool,
  rule                            : bool,
  hand_writte_rule                : bool,
  induct_on_subterm               : bool*)
  };

type datapoints = datapoint list;

fun int_to_bool 1 = true
  | int_to_bool 0 = false
  | int_to_bool _ = error "int_to_bool";

fun read_one_line (line:string) =
  let
    val (file_name::numbers_as_strings) = String.tokens (fn c=> str c = ",") line: string list;
    val numbers_as_ints = map (Int.fromString) numbers_as_strings: int option list;
    val result =
          {file_name                        = file_name,
           line_number                      = nth numbers_as_ints 0 |> the,
           rank                             = nth numbers_as_ints 1,
           numb_of_candidates_after_step_1  = nth numbers_as_ints 2  |> the,
           numb_of_candidates_after_step_2  = nth numbers_as_ints 3  |> the,
           numb_of_candidates_after_step_3  = nth numbers_as_ints 4  |> the,
           numb_of_candidates_after_step_4  = nth numbers_as_ints 5  |> the,
           numb_of_candidates_after_step_5  = nth numbers_as_ints 6  |> the,
           score                            = nth numbers_as_ints 7  |> the,
           execution_time                   = nth numbers_as_ints 8  |> the(*,
           arbitrary                        = nth numbers_as_ints 7  |> the |> int_to_bool,
           rule                             = nth numbers_as_ints 8  |> the |> int_to_bool,
           hand_writte_rule                 = nth numbers_as_ints 9  |> the |> int_to_bool,
           induct_on_subterm                = nth numbers_as_ints 10 |> the |> int_to_bool*)
           };
  in
    result
  end;

val lines = get_lines path
  |> (map (try read_one_line))
 |> (fn x => (tracing (Int.toString (length x)) ; x))
  |> Utils.somes
 |> (fn x => (tracing (Int.toString (length x)) ; x))
: datapoints

\<close>
ML\<open>
fun real_to_percentage_with_precision (real:real) = (1000.0 * real |> Real.round |> Real.fromInt) / 10.0: real;
fun real_to_percentage_with_precision_str (real:real) = real_to_percentage_with_precision real |> Real.toString: string;
fun real_to_percentage     (real:real) = 100.0 * real |> Real.round             : int;
fun real_to_percentage_str (real:real) = real_to_percentage real |> Int.toString: string;
fun print_pair (label:string, coincidence_rate:real) =
  enclose "(" ")" (label ^ ", " ^ real_to_percentage_str coincidence_rate);
fun print_pair_with_precision (label:string, coincidence_rate:real) =
  enclose "(" ")" (label ^ ", " ^ real_to_percentage_with_precision_str coincidence_rate);
fun print_one_line (pairs:(string * real) list) =
  "\addplot coordinates {" ^ (String.concatWith " " (map print_pair_with_precision pairs)) ^ "};\n": string;

fun point_is_in_file (file_name:string) (point:datapoint)   = #file_name point = file_name;
fun points_in_file   (file_name:string) (points:datapoints) = filter (point_is_in_file file_name) points;

fun point_is_among_top_n (top_n:int) (point:datapoint) =
   Option.map (fn rank => rank <= top_n) (#rank point)
|> Utils.is_some_true;

fun points_among_top_n (top_n:int) (points:datapoints) = filter (point_is_among_top_n top_n) points;

fun get_coincidence_rate_top_n (points:datapoints) (top_n:int) =
  let
    val numb_of_points           = points |> length |> Real.fromInt: real;
    val datapoints_among_top_n   = points_among_top_n top_n points;
    val numb_of_points_among_top = datapoints_among_top_n |> length |> Real.fromInt: real;
  in
    (numb_of_points_among_top / numb_of_points): real
  end;
\<close>
ML\<open>
fun get_coincidence_rate_for_file_for_top_n (points:datapoints) (file_name:string) (top_n:int) =
  let
    val datapoints_in_file                 = points_in_file file_name points
  in
    get_coincidence_rate_top_n datapoints_in_file top_n: real
  end;

fun datapoints_to_all_file_names (points:datapoints) = map #file_name points |> distinct (op =);

fun datapoints_to_coincidence_rates (points:datapoints) (top_ns:ints) = map (get_coincidence_rate_top_n points) top_ns: real list;

fun attach_file_name_to_coincidence_rates (file_name:string) (rates) = map (fn rate => (file_name, rate)) rates;
\<close>
ML\<open>
fun datapoints_to_coincidence_rate_pairs_for_one_file (points:datapoints) (file_name:string) (top_ns:ints) =
  map (fn top_n => (file_name, get_coincidence_rate_for_file_for_top_n points file_name top_n)) top_ns: (string * real) list;
\<close>

ML\<open>
fun datapoints_to_coincidence_rate_pairs (points:datapoints) (top_ns:ints) =
  let
val _ = tracing (Int.toString (length points));
    val file_names                      = datapoints_to_all_file_names points;
    val overall_coincidence_rates       = datapoints_to_coincidence_rates points top_ns |> attach_file_name_to_coincidence_rates "overall": (string * real) list;
    val coincidence_rates_for_each_file = map (fn file_name => datapoints_to_coincidence_rate_pairs_for_one_file points file_name top_ns) file_names: (string * real) list list;
    val all_pairs                       = coincidence_rates_for_each_file @ [overall_coincidence_rates]: (string * real) list list;
  in
    all_pairs |> Matrix.matrix_to_row_of_columns_matrix |> Matrix.transpose_rcmatrix |> the |> Matrix.row_of_columns_matrix_to_matrix
  end;
\<close>


ML\<open> val tikz_for_coincidence_rates = get_coincidence_rate_for_file_for_top_n lines "~/Workplace/PSL/Smart_Induct/Evaluation/DFS.thy" 1;\<close>

ML\<open>(*result*)
fun from_pair_matrix_to_tikz_barplot (pairs) = pairs
|> map print_one_line
|> (fn addplots:strings => (String.concatWith ", " (datapoints_to_all_file_names lines) ^ "\n") :: addplots)
|> String.concat
|> tracing;

val _ = lines;

val coincidence_rates_for_files = 
   datapoints_to_coincidence_rate_pairs lines [1,2,3,5,8,10]
|> from_pair_matrix_to_tikz_barplot;

(*
~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, ~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, ~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, ~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, ~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, ~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, ~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, ~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, ~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy
ddplot coordinates {(~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, 75.0) (~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, 60.0) (~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, 36.5) (~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, 44.4) (~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, 60.2) (~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, 25.6) (~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, 77.8) (~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy, 18.2) (overall, 52.8)};
ddplot coordinates {(~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, 75.0) (~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, 80.0) (~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, 59.6) (~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, 77.8) (~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, 69.3) (~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, 41.0) (~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, 77.8) (~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy, 81.8) (overall, 67.7)};
ddplot coordinates {(~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, 75.0) (~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, 80.0) (~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, 67.3) (~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, 88.9) (~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, 72.7) (~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, 66.7) (~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, 77.8) (~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy, 81.8) (overall, 74.8)};
ddplot coordinates {(~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, 75.0) (~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, 80.0) (~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, 71.2) (~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, 88.9) (~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, 79.5) (~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, 66.7) (~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy, 100.0) (overall, 79.5)};
ddplot coordinates {(~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, 83.3) (~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, 80.0) (~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, 75.0) (~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, 88.9) (~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, 81.8) (~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, 66.7) (~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy, 100.0) (overall, 81.5)};
ddplot coordinates {(~/Workplace/PSL/SeLFiE/Evaluation/Challenge1A.thy, 83.3) (~/Workplace/PSL/SeLFiE/Evaluation/DFS.thy, 80.0) (~/Workplace/PSL/SeLFiE/Evaluation/Goodstein_Lambda.thy, 75.0) (~/Workplace/PSL/SeLFiE/Evaluation/Boolean_Expression_Checkers.thy, 88.9) (~/Workplace/PSL/SeLFiE/Evaluation/Hybrid_Logic.thy, 81.8) (~/Workplace/PSL/SeLFiE/Evaluation/BinomialHeap.thy, 69.2) (~/Workplace/PSL/SeLFiE/Evaluation/PST_RBT.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/KD_Tree.thy, 100.0) (~/Workplace/PSL/SeLFiE/Evaluation/Nearest_Neighbors.thy, 100.0) (overall, 81.9)};
*)
\<close>

declare [[ML_print_depth=200]]

ML\<open>(*result*)
fun sort_datapoints_wrt_execution_time (points:datapoints) =
 sort (fn (poin1, poin2) => Int.compare (#execution_time poin1, #execution_time poin2)) points: datapoints;
       
fun milli_sec_to_sec_with_precision (milli:int) =
  (((Real.fromInt milli) / 100.0) |> Real.round |> Real.fromInt) / 10.0;

val pairs_of_successful_points =
   sort_datapoints_wrt_execution_time lines
|> Utils.index
|> filter (is_some o #rank o snd)
|> map (fn (index, point) => (index, #execution_time point |> milli_sec_to_sec_with_precision));

val pairs_of_failure_points =
   sort_datapoints_wrt_execution_time lines
|> Utils.index
|> filter (is_none o #rank o snd)
|> map (fn (index, point) => (index, #execution_time point |> milli_sec_to_sec_with_precision));

fun print_pairs_real pairs = map (fn (index, time) => "(" ^ Int.toString index ^ ", " ^ Real.toString time ^ ")") pairs |> String.concatWith " ";

print_pairs_real pairs_of_successful_points;
print_pairs_real pairs_of_failure_points;
\<close>

ML\<open>
val numb_of_Challenge = 12.0;
val numb_of_DFS       = 10.0;
val numb_of_Goodstein = 52.0;
val numb_of_NN        = 11.0;
val numb_of_PST       = 24.0;
val total_numb        = length lines |> Real.fromInt;


val proportion_of_Challenge = ((Real.fromInt o Real.round) ((numb_of_Challenge / total_numb) * 1000.0)) / 10.0;
val proportion_of_DFS       = ((Real.fromInt o Real.round) ((numb_of_DFS       / total_numb) * 1000.0)) / 10.0;
val proportion_of_Goodstein = ((Real.fromInt o Real.round) ((numb_of_Goodstein / total_numb) * 1000.0)) / 10.0;
val proportion_of_NN        = ((Real.fromInt o Real.round) ((numb_of_NN        / total_numb) * 1000.0)) / 10.0;
val proportion_of_PST       = ((Real.fromInt o Real.round) ((numb_of_PST       / total_numb) * 1000.0)) / 10.0;
val proportion_of_Challenge = ((Real.fromInt o Real.round) ((numb_of_Challenge / total_numb) * 1000.0)) / 10.0;
val s = 24.0/109.0
\<close>

(*
\begin{tikzpicture}
\begin{axis}[
    xbar,
    xmin=0.0,
    width=1.0\textwidth,
%    height=4cm,
    enlarge x limits={rel=0.13,upper},
    ytick={1,2,3},
    yticklabels={{Térritmus},{Mozgásritmus},{Formaritmus}},
    enlarge y limits=0.4,
    xlabel={The use of \texttt{arbitrary} for \induct{} [\%]},
    ytick=data,
    nodes near coords,
    nodes near coords align=horizontal
]
\addplot [draw=black, fill=cyan!40!black] coordinates {
    (58.3333333333,1)
    (91.6666666667,2)
    (90.0,3)

};
\end{axis}
\end{tikzpicture}
*)

end