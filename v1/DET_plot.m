%------------------------------
%load speaker detection output scores
load cosine_scores_ture
load cosine_scores_false
load lda_scores_ture
load lda_scores_false
load plda_scores_ture
load plda_scores_false

true(:,1) = cosine_scores_ture;
true(:,2) = lda_scores_ture;
true(:,3) = plda_scores_ture;
false(:,1) = cosine_scores_false;
false(:,2) = lda_scores_false;
false(:,3) = plda_scores_false;
plot_code = ['r' 'g' 'b'];

Pmiss_min = 0.001;
Pmiss_max = 0.40;
Pfa_min = 0.001;
Pfa_max = 0.40;
Set_DET_limits(Pmiss_min,Pmiss_max,Pfa_min,Pfa_max);

Set_DCF (10, 1, 0.01);

figure;
title('Speaker Detection Performance');
hold on;

for n=1:3
  True_scores = true(:,n);
  False_scores = false(:,n);
  
  [P_miss,P_fa] = Compute_DET(True_scores,False_scores);
  Plot_DET (P_miss,P_fa,plot_code(n));
  
  C_miss = 1;
  C_fa = 1;
  P_target = 0.5;
  Set_DCF(C_miss,C_fa,P_target);
  [DCF_opt, Popt_miss, Popt_fa] = Min_DCF(P_miss,P_fa);
  Plot_DET (Popt_miss,Popt_fa,'ko');
end
legend('Cos','Cos.DCF','Lda','Lda.DCF','Plda','Plda.DCF');