(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require map.Map.
Require map.Const.
Require int.Int.

Axiom ident : Type.
Parameter ident_WhyType : WhyType ident.
Existing Instance ident_WhyType.

Axiom ident_eq_dec : forall (i1:ident) (i2:ident), (i1 = i2) \/ ~ (i1 = i2).

Parameter mk_ident: Z -> ident.

Axiom mk_ident_inj : forall (i:Z) (j:Z), ((mk_ident i) = (mk_ident j)) ->
  (i = j).

(* Why3 assumption *)
Inductive operator :=
  | Oplus : operator
  | Ominus : operator
  | Omult : operator.
Axiom operator_WhyType : WhyType operator.
Existing Instance operator_WhyType.

(* Why3 assumption *)
Inductive expr :=
  | Econst : Z -> expr
  | Evar : ident -> expr
  | Ebin : expr -> operator -> expr -> expr.
Axiom expr_WhyType : WhyType expr.
Existing Instance expr_WhyType.

(* Why3 assumption *)
Inductive stmt :=
  | Sskip : stmt
  | Sassign : ident -> expr -> stmt
  | Sseq : stmt -> stmt -> stmt
  | Sif : expr -> stmt -> stmt -> stmt
  | Swhile : expr -> stmt -> stmt.
Axiom stmt_WhyType : WhyType stmt.
Existing Instance stmt_WhyType.

Axiom check_skip : forall (s:stmt), (s = Sskip) \/ ~ (s = Sskip).

(* Why3 assumption *)
Definition state := (map.Map.map ident Z).

(* Why3 assumption *)
Definition eval_bin (x:Z) (op:operator) (y:Z): Z :=
  match op with
  | Oplus => (x + y)%Z
  | Ominus => (x - y)%Z
  | Omult => (x * y)%Z
  end.

(* Why3 assumption *)
Fixpoint eval_expr (s:(map.Map.map ident Z)) (e:expr) {struct e}: Z :=
  match e with
  | (Econst n) => n
  | (Evar x) => (map.Map.get s x)
  | (Ebin e1 op e2) => (eval_bin (eval_expr s e1) op (eval_expr s e2))
  end.

(* Why3 assumption *)
Inductive one_step: (map.Map.map ident Z) -> stmt -> (map.Map.map ident Z) ->
  stmt -> Prop :=
  | one_step_assign : forall (s:(map.Map.map ident Z)) (x:ident) (e:expr),
      (one_step s (Sassign x e) (map.Map.set s x (eval_expr s e)) Sskip)
  | one_step_seq : forall (s:(map.Map.map ident Z)) (s':(map.Map.map ident
      Z)) (i1:stmt) (i1':stmt) (i2:stmt), (one_step s i1 s' i1') -> (one_step
      s (Sseq i1 i2) s' (Sseq i1' i2))
  | one_step_seq_skip : forall (s:(map.Map.map ident Z)) (i:stmt), (one_step
      s (Sseq Sskip i) s i)
  | one_step_if_true : forall (s:(map.Map.map ident Z)) (e:expr) (i1:stmt)
      (i2:stmt), (~ ((eval_expr s e) = 0%Z)) -> (one_step s (Sif e i1 i2) s
      i1)
  | one_step_if_false : forall (s:(map.Map.map ident Z)) (e:expr) (i1:stmt)
      (i2:stmt), ((eval_expr s e) = 0%Z) -> (one_step s (Sif e i1 i2) s i2)
  | one_step_while_true : forall (s:(map.Map.map ident Z)) (e:expr) (i:stmt),
      (~ ((eval_expr s e) = 0%Z)) -> (one_step s (Swhile e i) s (Sseq i
      (Swhile e i)))
  | one_step_while_false : forall (s:(map.Map.map ident Z)) (e:expr)
      (i:stmt), ((eval_expr s e) = 0%Z) -> (one_step s (Swhile e i) s Sskip).

Axiom progress : forall (s:(map.Map.map ident Z)) (i:stmt),
  (~ (i = Sskip)) -> exists s':(map.Map.map ident Z), exists i':stmt,
  (one_step s i s' i').

(* Why3 assumption *)
Inductive many_steps: (map.Map.map ident Z) -> stmt -> (map.Map.map ident
  Z) -> stmt -> Z -> Prop :=
  | many_steps_refl : forall (s:(map.Map.map ident Z)) (i:stmt), (many_steps
      s i s i 0%Z)
  | many_steps_trans : forall (s1:(map.Map.map ident Z)) (s2:(map.Map.map
      ident Z)) (s3:(map.Map.map ident Z)) (i1:stmt) (i2:stmt) (i3:stmt)
      (n:Z), (one_step s1 i1 s2 i2) -> ((many_steps s2 i2 s3 i3 n) ->
      (many_steps s1 i1 s3 i3 (n + 1%Z)%Z)).

Axiom steps_non_neg : forall (s1:(map.Map.map ident Z)) (s2:(map.Map.map
  ident Z)) (i1:stmt) (i2:stmt) (n:Z), (many_steps s1 i1 s2 i2 n) ->
  (0%Z <= n)%Z.

Axiom many_steps_seq : forall (s1:(map.Map.map ident Z)) (s3:(map.Map.map
  ident Z)) (i1:stmt) (i2:stmt) (n:Z), (many_steps s1 (Sseq i1 i2) s3 Sskip
  n) -> exists s2:(map.Map.map ident Z), exists n1:Z, exists n2:Z,
  (many_steps s1 i1 s2 Sskip n1) /\ ((many_steps s2 i2 s3 Sskip n2) /\
  (n = ((1%Z + n1)%Z + n2)%Z)).

(* Why3 assumption *)
Inductive fmla :=
  | Fterm : expr -> fmla
  | Fand : fmla -> fmla -> fmla
  | Fnot : fmla -> fmla
  | Fimplies : fmla -> fmla -> fmla.
Axiom fmla_WhyType : WhyType fmla.
Existing Instance fmla_WhyType.

(* Why3 assumption *)
Fixpoint eval_fmla (s:(map.Map.map ident Z)) (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm e) => ~ ((eval_expr s e) = 0%Z)
  | (Fand f1 f2) => (eval_fmla s f1) /\ (eval_fmla s f2)
  | (Fnot f1) => ~ (eval_fmla s f1)
  | (Fimplies f1 f2) => (eval_fmla s f1) -> (eval_fmla s f2)
  end.

Parameter subst_expr: expr -> ident -> expr -> expr.

Axiom subst_expr_def : forall (e:expr) (x:ident) (t:expr),
  match e with
  | (Econst _) => ((subst_expr e x t) = e)
  | (Evar y) => ((x = y) -> ((subst_expr e x t) = t)) /\ ((~ (x = y)) ->
      ((subst_expr e x t) = e))
  | (Ebin e1 op e2) => ((subst_expr e x t) = (Ebin (subst_expr e1 x t) op
      (subst_expr e2 x t)))
  end.

Axiom eval_subst_expr : forall (s:(map.Map.map ident Z)) (e:expr) (x:ident)
  (t:expr), ((eval_expr s (subst_expr e x t)) = (eval_expr (map.Map.set s x
  (eval_expr s t)) e)).

(* Why3 assumption *)
Fixpoint subst (f:fmla) (x:ident) (t:expr) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_expr e x t))
  | (Fand f1 f2) => (Fand (subst f1 x t) (subst f2 x t))
  | (Fnot f1) => (Fnot (subst f1 x t))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x t) (subst f2 x t))
  end.



(* Why3 goal *)
Theorem eval_subst : forall (s:(map.Map.map ident Z)) (f:fmla) (x:ident)
  (t:expr), (eval_fmla s (subst f x t)) <-> (eval_fmla (map.Map.set s x
  (eval_expr s t)) f).
(* Why3 intros s f x t. *)
(* YOU MAY EDIT THE PROOF BELOW *)
induction f.
unfold eval_fmla, subst in *.
intros x t.
rewrite <- eval_subst_expr; tauto.

simpl.
intros x t.
rewrite IHf1.
rewrite IHf2.
tauto.

simpl.
intros x t.
rewrite IHf.
tauto.

simpl.
intros x t.
rewrite IHf1.
rewrite IHf2.
tauto.
Qed.

