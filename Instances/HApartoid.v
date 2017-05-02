Add Rec LoadPath "/home/zeimer/Code/Coq/CoqCat".

Require Export Cat.
Require Import InitTerm.
Require Import BinProdCoprod.
Require Import BigProdCoprod.
Require Import Equalizer.

Class HApartoid : Type :=
{
    carrier : Type;
    hneq : forall (A B : Type), A -> B -> Prop;
    hneq_irrefl : forall (A : Type) (x : A), ~ hneq A A x x;
    hneq_sym : forall (A B : Type) (x : A) (y : B),
      hneq A B x y -> hneq B A y x;
    hneq_cotrans : forall (A B C : Type) (x : A) (y : B) (z : C),
      hneq A B x y -> hneq C A z x \/ hneq C B z y
}.

Arguments hneq [HApartoid] [A] [B] _ _.

Coercion carrier : HApartoid >-> Sortclass.

Definition HApartoidHom (X Y : HApartoid) : Type :=
    {f : X -> Y | forall x x' : carrier, ~ hneq x x' -> ~ hneq (f x) (f x')}.

Definition HApartoidHom_Fun (X Y : HApartoid) (f : HApartoidHom X Y)
    : X -> Y := proj1_sig f.
Coercion HApartoidHom_Fun : HApartoidHom >-> Funclass.

Definition HApartoidComp (X Y Z : HApartoid)
    (f : HApartoidHom X Y) (g : HApartoidHom Y Z)
    : HApartoidHom X Z.
Proof.
  red. exists (fun x : X => g (f x)). intros. intro.
  destruct f, g; simpl in *. apply (n0 (x0 x) (x0 x')).
   