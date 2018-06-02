(* Property from Case-Analysis for Rippling and Inductive Proof, 
   Moa Johansson, Lucas Dixon and Alan Bundy, ITP 2010. 
   This Isabelle theory is produced using the TIP tool offered at the following website: 
     https://github.com/tip-org/tools 
   This file was originally provided as part of TIP benchmark at the following website:
     https://github.com/tip-org/benchmarks 
   Yutaka Nagashima at CIIRC, CTU changed the TIP output theory file slightly 
   to make it compatible with Isabelle2017.
   Some proofs were added by Yutaka Nagashima.*)
theory TIP_prop_48
  imports "../../Test_Base"
begin

datatype 'a list = nil2 | cons2 "'a" "'a list"

datatype Nat = Z | S "Nat"

fun x :: "'a list => 'a list => 'a list" where
  "x (nil2) z = z"
| "x (cons2 z2 xs) z = cons2 z2 (x xs z)"

fun last :: "Nat list => Nat" where
  "last (nil2) = Z"
| "last (cons2 z (nil2)) = z"
| "last (cons2 z (cons2 x2 x3)) = last (cons2 x2 x3)"

fun butlast :: "'a list => 'a list" where
  "butlast (nil2) = nil2"
| "butlast (cons2 z (nil2)) = nil2"
| "butlast (cons2 z (cons2 x2 x3)) =
     cons2 z (butlast (cons2 x2 x3))"

theorem property0 :(*Manually fixed TIP's bug.\<rightarrow> still broken.*)
  "((case xs of
         nil2 => True
         | cons2 y z => False) ==>
      ((x (butlast xs) (cons2 (last xs) (nil2))) = xs))"
  nitpick
  oops

end