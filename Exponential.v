Add Rec LoadPath "/home/zeimer/Code/Coq".

Require Export Cat.
Require Export InitTerm.
Require Export BinProdCoprod.

Definition exponential {C : Cat} {hp : has_products C}
  (X Y E : Ob C) (eval : Hom (prodOb E X) Y) : Prop :=
    forall (Z : Ob C) (e : Hom (prodOb Z X) Y),
      exists!! u : Hom Z E, ProductFunctor_fmap u (id X) .> eval == e.

Definition exponential_skolem {C : Cat} {hp : has_products C}
  (X Y E : Ob C) (eval : Hom (prodOb E X) Y)
  (curry : forall E' : Ob C, Hom (prodOb E' X) Y -> Hom E' E) : Prop :=
    forall (E' : Ob C) (eval' : Hom (prodOb E' X) Y),
      setoid_unique (fun u : Hom E' E =>
        ProductFunctor_fmap u (id X) .> eval == eval') (curry E' eval').

Class has_exponentials (C : Cat) {hp : has_products C} : Type :=
{
    expOb : Ob C -> Ob C -> Ob C;
    eval : forall X Y : Ob C,
      Hom (prodOb (expOb X Y) X) Y;
    curry : forall {X Y Z : Ob C},
      Hom (prodOb Z X) Y -> Hom Z (expOb X Y);
    curry_Proper : forall X Y Z : Ob C,
      Proper (equiv ==> equiv) (@curry X Y Z);
    is_exponential : forall (X Y : Ob C),
      exponential_skolem X Y (expOb X Y) (eval X Y) (@curry X Y)
}.

Arguments expOb [C] [hp] [has_exponentials] _ _.
Arguments eval [C] [hp] [has_exponentials] [X] [Y].
Arguments curry [C] [hp] [has_exponentials] [X] [Y] [Z] _.

Arguments ProductFunctor [C] [hp].

Notation "f ×' g" := (ProductFunctor_fmap f g) (at level 40).

Definition uncurry
    {C : Cat} {hp : has_products C} {he : has_exponentials C}
    {X Y Z : Ob C} (f : Hom Z (expOb X Y)) : Hom (prodOb Z X) Y
    := f ×' (id X) .> eval.

Theorem uncurry_Proper :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y Z : Ob C), Proper (equiv ==> equiv) (@uncurry C hp he X Y Z).
Proof.
  unfold Proper, respectful, uncurry. intros.
  cut (x ×' id X == y ×' id X).
    intro H'. rewrite H'. reflexivity.
    apply ProductFunctor_fmap_Proper; [assumption | reflexivity].
Qed.

Theorem curry_uncurry :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y Z : Ob C) (f : Hom X (expOb Y Z)),
      curry (uncurry f) == f.
Proof.
  unfold uncurry; destruct he; simpl; intros.
  do 2 red in is_exponential0.
  destruct (is_exponential0 Y Z X (f ×' id Y .> (eval0 _ _))) as [H1 H2].
  apply H2. reflexivity.
Qed.

Theorem uncurry_curry :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y Z : Ob C) (f : Hom (prodOb X Y) Z),
      uncurry (curry f) == f.
Proof.
  destruct he; simpl; intros. do 2 red in is_exponential0.
  unfold uncurry. destruct (is_exponential0 Y Z X f).
  exact H.
Qed.

Theorem curry_eval :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y : Ob C), curry eval == id (expOb X Y).
Proof.
  destruct he; simpl; intros.
  do 2 red in is_exponential0.
  destruct (is_exponential0 _ _ _ (eval0 X Y)) as [H1 H2].
  apply (H2 (id _)). rewrite ProductFunctor_fmap_pres_id.
  rewrite id_left. reflexivity.
Qed.

Theorem curry_comp :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y Z A : Ob C) (f : Hom Y Z) (g : Hom Z A),
      @curry C hp he X A _ (eval .> f .> g) == curry (eval .> f) .> curry (eval .> g).
Proof.
  intros. destruct he; simpl in *.
  destruct (is_exponential0 _ _ _ ((eval0 X Y .> f) .> g)).
  destruct (is_exponential0 _ _ _ (eval0 X Y .> f)).
  destruct (is_exponential0 _ _ _ (eval0 X Z .> g)).
  apply H0. pose (P := ProductFunctor_fmap_Proper). rewrite <- (id_left X).
  rewrite ProductFunctor_fmap_pres_comp. rewrite comp_assoc.
  rewrite H3. rewrite <- comp_assoc. rewrite H1. reflexivity.
Qed.
(*Theorem curry_eval' :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y Z : Ob C) f, curry (eval .> f) == f.*)

 


Theorem uncurry_id :
  forall (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X Y : Ob C), uncurry (id (expOb X Y)) == eval.
Proof.
  destruct he; simpl; intros.
  do 2 red in is_exponential0.
  destruct (is_exponential0 _ _ _ (eval0 X Y)) as [H1 H2].
  unfold uncurry. rewrite ProductFunctor_fmap_pres_id. cat.
Qed.

Theorem exponential_unique :
    forall (C : Cat) (hp : has_products C) (X Y : Ob C)
    (E : Ob C) (eval : Hom (prodOb E X) Y)
    (E' : Ob C) (eval' : Hom (prodOb E' X) Y),
        exponential X Y E eval -> exponential X Y E' eval' -> E ~ E'.
Proof.
  intros. red in H, H0.
  destruct (H0 E eval0) as [u [Hu1 Hu2]], (H E' eval') as [u' [Hu'1 Hu'2]].
  exists u, u'. split.
    destruct (H E eval0) as [f [Hf1 Hf2]].
    assert (f == id E).
      apply Hf2. rewrite ProductFunctor_fmap_pres_id, id_left. reflexivity.
      rewrite <- H1. symmetry. apply Hf2.
        rewrite <- Hu'1, <- comp_assoc,
        <- ProductFunctor_fmap_pres_comp in Hu1.
        assert (ProductFunctor_fmap (u .> u') (id X .> id X)
          == ProductFunctor_fmap (u .> u') (id X)).
          apply ProductFunctor_fmap_Proper; auto. reflexivity.
          rewrite H2 in Hu1. assumption.
    destruct (H0 E' eval') as [f [Hf1 Hf2]].
    assert (f == id E').
      apply Hf2. rewrite ProductFunctor_fmap_pres_id, id_left. reflexivity.
      rewrite <- H1. symmetry. apply Hf2.
        rewrite <- Hu1, <- comp_assoc,
        <- ProductFunctor_fmap_pres_comp in Hu'1.
        assert (ProductFunctor_fmap (u' .> u) (id X .> id X)
          == ProductFunctor_fmap (u' .> u) (id X)).
          apply ProductFunctor_fmap_Proper; auto. reflexivity.
          rewrite H2 in Hu'1. assumption.
Defined.

Theorem exponential_skolem_unique_long :
    forall (C : Cat) (hp : has_products C) (X Y : Ob C)
    (E : Ob C) (eval : Hom (prodOb E X) Y)
      (curry : forall Z : Ob C, Hom (prodOb Z X) Y -> Hom Z E)
    (E' : Ob C) (eval' : Hom (prodOb E' X) Y)
      (curry' : forall Z : Ob C, Hom (prodOb Z X) Y -> Hom Z E'),
        exponential_skolem X Y E eval curry ->
        exponential_skolem X Y E' eval' curry'
        -> E ~ E'.
Proof.
  intros. red. do 2 red in H. do 2 red in H0.
  exists (curry' E eval0). red. exists (curry0 E' eval').
  split.
    destruct (H E eval0) as [H1 H2].
      rewrite <- (H2 (curry' E eval0 .> curry0 E' eval')).
        rewrite (H2 (id E)).
          reflexivity.
          rewrite ProductFunctor_fmap_pres_id, id_left. reflexivity.
        rewrite ProductFunctor_fmap_pres_comp_l.
          destruct (H E' eval'), (H0 E eval0).
            rewrite comp_assoc. rewrite H3. rewrite H5. reflexivity.
    destruct (H0 E' eval') as [H1 H2].
      rewrite <- (H2 (curry0 E' eval' .> curry' E eval0)).
        rewrite (H2 (id E')).
          reflexivity.
          rewrite ProductFunctor_fmap_pres_id, id_left. reflexivity.
        rewrite ProductFunctor_fmap_pres_comp_l.
          destruct (H E' eval'), (H0 E eval0).
            rewrite comp_assoc. rewrite H5. rewrite H3. reflexivity.
Qed.

Theorem has_exponentials_unique :
  forall (C : Cat) (hp : has_products C) (hp' : has_products C)
    (he : has_exponentials C) (he' : has_exponentials C) (X Y : Ob C),
      @expOb C hp he X Y ~ @expOb C hp' he' X Y.
Proof.
  intros. destruct he, he'. simpl in *.
Abort.

Print Functor.

Instance Functor (C : Cat) (hp : has_products C) (he : has_exponentials C)
    (X : Ob C) : Functor C C :=
{
    fob := fun Y : Ob C => expOb X Y;
    fmap := fun (A B : Ob C) (f : Hom A B) => curry (eval .> f)
}.
Proof.
  unfold Proper, respectful; intros. apply curry_Proper.
    rewrite H. reflexivity.
  intros. rewrite <- curry_comp. apply curry_Proper. cat.
  intros. rewrite <- curry_eval. apply curry_Proper. cat.
Defined.