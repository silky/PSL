(*
 * This file "Induction_Demo.thy" was originally developed by Tobias Nipkow and Gerwin Klein
 * as Isabelle theory files accompanying their book "Concrete Semantics".
 * 
 * The PDF file of the book and the original Isabelle theory files are available 
 * at the following website:
 *   http://concrete-semantics.org/index.html
 *
 *)
theory Induction_Demo
  imports Main "../LiFtEr"
begin

(* HINT FOR ONLINE DEMO
   Start your first proof attempt with
   itrev xs [] = rev xs
   then generalize by introducing ys, and finally quantify over ys.
   Each generalization should be motivated by the previous failed
   proof attempt.
*)

fun itrev :: "'a list \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "itrev [] ys = ys" |
  "itrev (x#xs) ys = itrev xs (x#ys)"

ML{* (* Example assertions in LiFtEr. *)
local

open LiFtEr_Util LiFtEr;
infix And Imply Is_An_Arg_Of Is_Rule_Of Is_Nth_Ind Is_In_Trm_Loc Is_In_Trm_Str;

in

(* Example 1-a *)
val all_ind_term_are_non_const_wo_syntactic_sugar =
 All_Ind (Trm 1,
   Some_Trm_Occ (Trm_Occ 1,
       Trm_Occ_Is_Of_Trm (Trm_Occ 1, Trm 1)
     And
       Not (Is_Cnst (Trm_Occ 1)))): assrt;

(* Example 1-b *)
val all_ind_term_are_non_const_with_syntactic_sugar =
 All_Ind (Trm 1,
   Some_Trm_Occ_Of (Trm_Occ 1, Trm 1,
     Not (Is_Cnst (Trm_Occ 1)))): assrt;

(* Example 2 *)
val all_ind_terms_have_an_occ_as_variable_at_bottom =
 All_Ind (Trm 1,
   Some_Trm_Occ_Of (Trm_Occ 1, Trm 1,
       Is_Atom (Trm_Occ 1)
     Imply
       Is_At_Deepest (Trm_Occ 1)));

(* Example 3 *)
val all_ind_vars_are_arguments_of_a_recursive_function =
Some_Trm (Trm 1,
  Some_Trm_Occ_Of (Trm_Occ 1, Trm 1,
    All_Ind (Trm 2,
      Some_Trm_Occ_Of (Trm_Occ 2, Trm 2,
           Is_Recursive_Cnst (Trm_Occ 1)
         And
           (Trm_Occ 2 Is_An_Arg_Of Trm_Occ 1)))));

(* Example 4 *)
val all_ind_vars_are_arguments_of_a_rec_func_where_pattern_match_is_complete =
 Not (Some_Rule (Rule 1, True))
Imply
 Some_Trm (Trm 1,
  Some_Trm_Occ_Of (Trm_Occ 1, Trm 1,
    Is_Recursive_Cnst (Trm_Occ 1)
   And
    All_Ind (Trm 2,
      Some_Trm_Occ_Of (Trm_Occ 2, Trm 2,
       Some_Numb (Numb 1,
         Pattern (Numb 1, Trm_Occ 1, All_Constr)
        And
         Is_Nth_Arg_Of (Trm_Occ 2, Numb 1, Trm_Occ 1))))));

(* Example 5 *)
val all_ind_terms_are_arguments_of_a_const_with_a_related_rule_in_order =
 Some_Rule (Rule 1, True)
Imply
 Some_Rule (Rule 1,
  Some_Trm (Trm 1,
   Some_Trm_Occ_Of (Trm_Occ 1, Trm 1,
    (Rule 1 Is_Rule_Of Trm_Occ 1)
    And
    (All_Ind (Trm 2,
     (Some_Trm_Occ_Of (Trm_Occ 2, Trm 2,
       Some_Numb (Numb 1,
         Is_Nth_Arg_Of (Trm_Occ 2, Numb 1, Trm_Occ 1)
        And
        (Trm 2 Is_Nth_Ind Numb 1)))))))));

(* Example 6-a *)
val ind_is_not_arb =
All_Arb (Trm 1,
 Not (Some_Ind (Trm 2,
  Are_Same_Trm (Trm 1, Trm 2))));

(* Example 6-b *)
val vars_in_ind_terms_are_generalized =
 Some_Ind (Trm 1,
  Some_Trm_Occ_Of (Trm_Occ 1, Trm 1,
   (All_Trm (Trm 2,
     Some_Trm_Occ_Of (Trm_Occ 2, Trm 2,
       ((Trm_Occ 2 Is_In_Trm_Loc Trm_Occ 1)
       And
        Is_Free (Trm_Occ 2))
      Imply
       Some_Arb (Trm 3,
        Are_Same_Trm (Trm 2, Trm 3)))))));

val Example6 = ind_is_not_arb And vars_in_ind_terms_are_generalized;

end;
*}

setup{* Apply_LiFtEr.update_assert "example_1a" all_ind_term_are_non_const_wo_syntactic_sugar;                           *}
setup{* Apply_LiFtEr.update_assert "example_1b" all_ind_term_are_non_const_with_syntactic_sugar;                         *}
setup{* Apply_LiFtEr.update_assert "example_2"  all_ind_terms_have_an_occ_as_variable_at_bottom;                         *}
setup{* Apply_LiFtEr.update_assert "example_3"  all_ind_vars_are_arguments_of_a_recursive_function;                      *}
setup{* Apply_LiFtEr.update_assert "example_4"  all_ind_vars_are_arguments_of_a_rec_func_where_pattern_match_is_complete;*}
setup{* Apply_LiFtEr.update_assert "example_5"  all_ind_terms_are_arguments_of_a_const_with_a_related_rule_in_order;     *}
setup{* Apply_LiFtEr.update_assert "example_6a" ind_is_not_arb;                                                          *}
setup{* Apply_LiFtEr.update_assert "example_6b" vars_in_ind_terms_are_generalized;                                       *}

ML{* (*Arguments for the induct method to attack "itrev xs ys = rev xs @ ys". *)
local

open LiFtEr;

in

(* Official solution of induction application by Tobias Nipkow and Gerwin Klein. *)
val official_solution_for_itrev_equals_rev =
Ind_Mods
 {ons   = [Ind_On  (Print "xs")],
  arbs  = [Ind_Arb (Print "ys")],
  rules = []
  }: ind_mods;

(* An example of inappropriate combination of arguments of the induct method. *)
val bad_answer_for_itrev_equals_rev =
Ind_Mods
 {ons   = [Ind_On  (Print "itrev")],
  arbs  = [Ind_Arb (Print "ys")],
  rules = []
  }: ind_mods;

(* Alternative proof found by Yutaka Nagashima.*)
val alt_prf =
Ind_Mods
 {ons   = [Ind_On  (Print "xs"), Ind_On (Print "ys")],
  arbs  = [],
  rules = [Ind_Rule "itrev.induct"]
  }: ind_mods;

end;
*}

setup{* Apply_LiFtEr.update_ind_mod "model_prf"   official_solution_for_itrev_equals_rev; *}
setup{* Apply_LiFtEr.update_ind_mod "bad_non_prf" bad_answer_for_itrev_equals_rev       ; *}
setup{* Apply_LiFtEr.update_ind_mod "alt_prf"     alt_prf                               ; *}

lemma "itrev xs ys = rev xs @ ys"
  (*The first argument to assert_LiFtEr_true is the identifier of a LiFtEr assertion, while
 *the second argument to assert_LiFtEr_true is the identifier of a combination of arguments to
 *the induct method.*)
  assert_LiFtEr_true  example_1a model_prf
  assert_LiFtEr_false example_1a bad_non_prf
  assert_LiFtEr_true  example_1b model_prf
  assert_LiFtEr_false example_1b bad_non_prf
  assert_LiFtEr_true  example_2  model_prf
  assert_LiFtEr_false example_2  bad_non_prf
  assert_LiFtEr_true  example_3  model_prf
  assert_LiFtEr_false example_3  bad_non_prf
  assert_LiFtEr_true  example_3  alt_prf
  assert_LiFtEr_true  example_4  model_prf
  assert_LiFtEr_false example_4  bad_non_prf
  assert_LiFtEr_true  example_4  alt_prf
  assert_LiFtEr_true  example_5  model_prf
  assert_LiFtEr_true  example_5  bad_non_prf (*This is a little unfortunate: example_5 alone cannot detect bad_non_prf is inappropriate.*)
  assert_LiFtEr_true  example_5  alt_prf
  assert_LiFtEr_true  example_6a model_prf
  assert_LiFtEr_true  example_6a bad_non_prf (*This is a little unfortunate: example_6a alone cannot detect bad_non_prf is inappropriate.*)
  assert_LiFtEr_true  example_6a alt_prf
  assert_LiFtEr_true  example_6b model_prf
  assert_LiFtEr_true  example_6b bad_non_prf (*This is a little unfortunate: example_6b alone cannot detect bad_non_prf is inappropriate.*)
  assert_LiFtEr_true  example_6b alt_prf
  oops

(*Model proof by Nipkow et.al.*)
lemma model_prf:"itrev xs ys = rev xs @ ys"
  apply(induct xs arbitrary: ys)
   apply(auto)
  done

(*Alternative proof by Yutaka Nagashima.*)
lemma alt_prf:"itrev xs ys = rev xs @ ys"
  apply(induct xs ys rule:itrev.induct)
   apply auto
  done

subsection{* Computation Induction *}

fun sep :: "'a \<Rightarrow> 'a list \<Rightarrow> 'a list" where
  "sep a [] = []" |
  "sep a [x] = [x]" |
  "sep a (x#y#zs) = x # a # sep a (y#zs)"

ML{* (*Arguments for the induct method to attack "map f (sep a xs) = sep (f a) (map f xs)". *)
local

open LiFtEr;

in

val official_solution_for_map_sep_equals_sep_map =
Ind_Mods
 {ons   = [Ind_On  (Print "a"), Ind_On  (Print "xs")],
  arbs  = [],
  rules = [Ind_Rule "sep.induct"]
  }: ind_mods;

val only_for_test =
Ind_Mods
 {ons   = [Ind_On  (Print "sep a xs")],
  arbs  = [Ind_Arb (Print "xs")],
  rules = []
  }: ind_mods;

end;
*}

setup{* Apply_LiFtEr.update_ind_mod "on_a_xs_rule_sep"   official_solution_for_map_sep_equals_sep_map; *}
setup{* Apply_LiFtEr.update_ind_mod "on_sep_a_xs_arb_xs" only_for_test;                                *}

lemma "map f (sep a xs) = sep (f a) (map f xs)"
  assert_LiFtEr_true example_2 on_a_xs_rule_sep
  assert_LiFtEr_true example_3 on_a_xs_rule_sep
  assert_LiFtEr_true example_4 on_a_xs_rule_sep
  assert_LiFtEr_true example_5 on_a_xs_rule_sep
  assert_LiFtEr_true example_6b on_sep_a_xs_arb_xs
  apply(induction a xs rule: Induction_Demo.sep.induct)
    apply auto
  done

end