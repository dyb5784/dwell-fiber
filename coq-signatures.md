# Coq Signature Index

### price_nonnegative

Theorem price_nonnegative :



### liveness_normal_operation

Theorem liveness_normal_operation :

Proof.

  intros s Hd Hp.



### liveness_under_attack

Theorem liveness_under_attack :

Proof.

  intros s Hd Hp.



### no_livelock

Theorem no_livelock :

Proof.

  intros s [inf_loop H]; admit.



### fair_pricing_theorem

Theorem fair_pricing_theorem :

Proof.

  intros ps H; unfold fair_pricing; intros p1 p2 A B C D; split; admit.



### attack_detection_bounded

Theorem attack_detection_bounded :

Proof.

  intros s Hd Hp.



### enforcement_terminates

Theorem enforcement_terminates :

Proof.

  intros s Hd Hp.



### process_safety_nonempty

Theorem process_safety_nonempty :

Proof.

  intros s H; admit. (* TODO: Add axiom that PIDs are bounded *)



### bounded_loss_preserves_dwell_bound

Lemma bounded_loss_preserves_dwell_bound :

Proof.

  intros original_stream pattern true_total_dwell Hvalid Htotal.



### update_price_monotonic

Lemma update_price_monotonic :

Proof.

  intros p d1 d2 Hp Hd1 Hd2.



### price_update_monotonic_dwell

Lemma price_update_monotonic_dwell :

Proof.

  intros p stream1 stream2 Hp Hdwell.



### bounded_price_under_loss

Lemma bounded_price_under_loss :

Proof.

  intros initial_price original_stream pattern Hprice Hvalid.



### lossy_stream_stability_bridge

Lemma lossy_stream_stability_bridge :

Proof.

  intros p stream pattern Hvalid.



### admm_resilience_to_event_loss

Theorem admm_resilience_to_event_loss :

Proof.

  (* This theorem would combine Lemma 3 with the stability results from dwell_stable.v



### price_nonnegative

Theorem price_nonnegative :

Proof.

  intros p d Hp.



### price_bounded

Theorem price_bounded :

Proof.

  intros p d Hp Hd_low Hd_high.



### convergence_to_budget

Theorem convergence_to_budget :

Proof.

  intros p d epsilon Hd Heps Hp.



### liveness_normal_mode

Theorem liveness_normal_mode :

Proof.

  intros d p Hd Hp.



### liveness_attack_mode

Theorem liveness_attack_mode :

Proof.

  intros d p thr Hd Hp Hthr.



### fairness_identical_processes

Theorem fairness_identical_processes :



### fairness_enforcement_symmetric

Theorem fairness_enforcement_symmetric :



### no_starvation

Theorem no_starvation :

Proof.

  intros d p Hd Hp.



### ransomware_detection

Theorem ransomware_detection :

Proof.

  intros d p thr Hatt Hthr Hα.



### encryption_unavoidable_detection

Theorem encryption_unavoidable_detection :



### no_evasion_by_burst

Theorem no_evasion_by_burst :



### dwell_fiber_guarantees

Theorem dwell_fiber_guarantees :

Proof.

  repeat split.



### test_total_dwell_empty

Lemma test_total_dwell_empty :

Proof.

  simpl.



### test_total_dwell_single

Lemma test_total_dwell_single :

Proof.

  simpl.



### test_total_dwell_multiple

Lemma test_total_dwell_multiple :

Proof.

  simpl.



### test_apply_loss_keep_all

Lemma test_apply_loss_keep_all :

Proof.

  intros n.



### test_apply_loss_drop_all

Lemma test_apply_loss_drop_all :

Proof.

  intros n.



### test_apply_loss_alternating

Lemma test_apply_loss_alternating :

Proof.

  simpl.



### test_valid_loss_pattern_keep_all

Lemma test_valid_loss_pattern_keep_all :

Proof.

  intros n.



### test_valid_loss_pattern_drop_all

Lemma test_valid_loss_pattern_drop_all :

Proof.

  intros Hdelta n.



### test_valid_loss_pattern_alternating

Lemma test_valid_loss_pattern_alternating :

Proof.

  intros Hburst.



### test_lemma1_keep_all

Lemma test_lemma1_keep_all :

Proof.

  intros n.



### test_lemma1_empty

Lemma test_lemma1_empty :

Proof.

  simpl.



### test_lemma1_delta_zero

Lemma test_lemma1_delta_zero :

Proof.

  intros Hdelta stream pattern Hvalid.



### test_update_price_monotonic_equal

Lemma test_update_price_monotonic_equal :

Proof.

  intros p d Hp Hd.



### test_price_update_monotonic_identical

Lemma test_price_update_monotonic_identical :

Proof.

  intros p stream Hp.



### test_price_increases_with_dwell

Lemma test_price_increases_with_dwell :

Proof.

  intros p d1 d2 Hp [Hd1_low Hd1_high] Hpos1 Hpos2.



### test_price_nonnegative

Lemma test_price_nonnegative :

Proof.

  intros p stream Hp.



### test_price_increase_bounded

Lemma test_price_increase_bounded :

Proof.

  intros p stream Hp.



### test_lemma3_keep_all

Lemma test_lemma3_keep_all :

Proof.

  intros p n.



### test_bridge_lemma

Lemma test_bridge_lemma :

Proof.

  intros p stream.



### test_complete_resilience_scenario

Lemma test_complete_resilience_scenario :

Proof.

  intros Hvalid.



### test_large_stream

Lemma test_large_stream :

Proof.

  simpl.



### test_max_burst_constraint

Lemma test_max_burst_constraint :

Proof.

  intros Hmax stream pattern Hvalid.



