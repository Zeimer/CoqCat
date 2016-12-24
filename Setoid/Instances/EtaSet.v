Add LoadPath "/home/zeimer/Code/Coq/CoqCat/Setoid/".

Require Export Cat.
Require Export InitTerm.
Require Import BinProdCoprod.
Require Import BigProdCoprod.
Require Import Equalizer.

Inductive eta : forall A : Set, A -> A -> Prop :=
    | eta_eq : forall (A : Set) (x y : A), x = y -> eta A x y
    | eta_r : forall (A B : Set) (f : A -> B),
        eta (A -> B) f (fun x : A => f x)
    | eta_l : forall (A B : Set) (f : A -> B),
        eta (A -> B) (fun x : A => f x) f.

Arguments eta [A] _ _.

Hint Constructors eta.

Instance eta_Equivalence (A : Set) : Equivalence (@eta A).
Proof.
  split; red; intros.
    constructor. auto.
    destruct H; subst.
      auto.
      apply eta_l.
      apply eta_r.
    destruct H; subst; auto.
Defined.

Instance EtaSet : Cat :=
{|
    Ob := Set;
    Hom := fun A B : Set => A -> B;
    HomSetoid := fun A B : Set =>
        {| equiv := @eta (A -> B) |};
    comp := fun (A B C : Set) (f : A -> B) (g : B -> C) (a : A) => g (f a);
    id := fun (A : Set) (a : A) => a
|}.
Proof.
  apply eta_Equivalence.
  (* Composition is proper *) unfold Proper, respectful. simpl. intros.
    destruct H.
  (* Category laws *) all:cat.
Defined.