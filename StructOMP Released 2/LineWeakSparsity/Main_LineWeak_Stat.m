%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% This script is used to obtain results for weak line structured sparsity 
%%%% Junzhou Huang, Tong Zhang, Dimitris Metaxas "Learning with Structured Sparsity"
%%%% By Junzhou Huang, Rutgers University,jzhuang@cs.rutgers.edu
%%%% Jan., 2009    Updated  Dec. 20, 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear;close all; 
%%% parameters
H=512; W=1; n=H*W; P=1; q=2; TT=0.5;
x1=tdist(101, H, 1.38);  %% 1.2 1.8
x2=tdist(302, H, 1.1);
x=x1-x2;
x=x*1000;
figure; plot(x);

[sv1,si1]=sort(abs(x), 'descend');
sv2=cumsum(sv1)/sum(sv1);
sind2=find(sv2>=0.95);%%%%%%%%%%%
K=sind2(1)
kt=length(find(x~=0));

Edge4=Edge4Index(H, W);
if W==1
    Edge4=Edge4(:,1:3);
end
[B, Bm]=GetBlocksMatrix(H, W, 1);
[BC, BCm]=GetBlocksConnectionMatrix(Bm, Edge4);
mq=size(Bm, 1); 

m_num=round(K*[2 2.5 3 3.5 4 4.5 5]);

for j=1:length(m_num),
    m=m_num(j)
for iter=1:10,    %%% adjust, how many time do you want to run experiments
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% step 2: Creating random projection matrix and measurements
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:P
        A=randn(m,n);item=sqrt(sum(A.*A,2));A=A./repmat(item, [1,n]);
        AA{i}=A; e=randn(m,1); e=e/norm(e(:));
        y{i}=AA{i}*x(:)+0.01*e;
    end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%% step 3: Sparse recovery
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%% Merhod 1: OMP
    tic;
    [xest1, Rec1] = OMP_CS(K,AA{1},y{1}, 0);
    time1=toc;
    
    %%%% Method 2: Lasso
    tt=cputime;
    x2 = SolveLasso(AA{1}, y{1}, size(AA{1},2), 'lasso', 100);
    xest2   = x2;
    time2=cputime-tt;  
 
     %%%% step 3: Group lasso
    Gsize=2; nGroups=n/Gsize; groups=[1:nGroups];
    groups=repmat(groups, [Gsize, 1]); groups=groups(:);
    tt=cputime;
    opts = spgSetParms('verbosity',0,'iterations',100,'bpTol',1e-04,'optTol',1e-04);
    xest3    = spg_group(AA{1},y{1},groups,0,opts);
    time3=cputime-tt;

   %%%% step 4: Group lasso
    Gsize=4; nGroups=n/Gsize; groups=[1:nGroups];
    groups=repmat(groups, [Gsize, 1]); groups=groups(:);
    tt=cputime;
    opts = spgSetParms('verbosity',0,'iterations',100,'bpTol',1e-04,'optTol',1e-04);
    xest4    = spg_group(AA{1},y{1},groups,0,opts);
    time4=cputime-tt;
    
   %%%% step 5: Group lasso
    Gsize=8; nGroups=n/Gsize; groups=[1:nGroups];
    groups=repmat(groups, [Gsize, 1]); groups=groups(:);
    tt=cputime;
    opts = spgSetParms('verbosity',0,'iterations',100,'bpTol',1e-04,'optTol',1e-04);
    xest5= spg_group(AA{1},y{1},groups,0,opts);
    time5=cputime-tt;
 
    %%% step 6: Group lasso
    Gsize=16; nGroups=n/Gsize; groups=[1:nGroups];
    groups=repmat(groups, [Gsize, 1]); groups=groups(:);
    tt=cputime;
    opts = spgSetParms('verbosity',0,'iterations',100,'bpTol',1e-04,'optTol',1e-04);
    xest6    = spg_group(AA{1},y{1},groups,0,opts);
    time6=cputime-tt; 
    
    %%% step 7: StructOMP
     tic;
    lamada=1;q=4;
    cl0=lamada*q*log2(mq)+K;
    [xest7, input, norm_save6] = GraphOMP_CS(cl0,AA{1},y{1}, Bm, BCm, lamada, []);
    time7=toc;
 
       
    diff1=norm(xest1(:)-x(:),2)/norm(x(:),2);
    diff2=norm(xest2(:)-x(:),2)/norm(x(:),2);  
    diff3=norm(xest3(:)-x(:),2)/norm(x(:),2);  
    diff4=norm(xest4(:)-x(:),2)/norm(x(:),2);  
    diff5=norm(xest5(:)-x(:),2)/norm(x(:),2);  
    diff6=norm(xest6(:)-x(:),2)/norm(x(:),2);  
    diff7=norm(xest7(:)-x(:),2)/norm(x(:),2);  

    result(:,iter)=[diff1,diff2,diff3,diff4 diff5 diff6 diff7 time1 time2, time3 time4 time5 time6 time7];
end
CompareResults(:,j)=mean(result, 2);
CompareResultsStd(:,j)=std(result,0, 2);
end
save CompareResults CompareResults;
save CompareResultsStd CompareResultsStd;

% load CompareResults;
% load CompareResultsStd

ms=5; ts=14;

figure; hold on;
errorbar(m_num/K, CompareResults(1,:), CompareResultsStd(1,:), 'bv-', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(2,:), CompareResultsStd(2,:), 'gd-', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(3,:), CompareResultsStd(3,:), 'ch-', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(4,:), CompareResultsStd(4,:), 'mh-.', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(5,:), CompareResultsStd(5,:), 'kh--', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(6,:), CompareResultsStd(6,:), 'yh-', 'linewidth', 3,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(7,:), CompareResultsStd(7,:), 'rp-', 'linewidth', 2,  'MarkerSize',ms);
ylabel('Recovery Error'); xlabel('Sample Size Ratio (n / k)');box on;
legend('OMP', 'Lasso', 'GroupLasso, gs=2','GroupLasso, gs=4','GroupLasso, gs=8','GroupLasso, gs=16','StructOMP');
axis([m_num(1)/K-0.5 m_num(end)/K+0.5 -0.1 0.6])
textobj = findobj('type', 'text');
set(textobj, 'fontsize', ts);
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',ts); 
h_xlabel = get(gca,'YLabel');
set(h_xlabel,'FontSize',ts); 



figure; hold on;
errorbar(m_num/K, CompareResults(8,:), CompareResultsStd(8,:), 'bv-', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(9,:), CompareResultsStd(9,:), 'gd-', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(10,:), CompareResultsStd(10,:), 'ch-', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(11,:), CompareResultsStd(11,:), 'mh-.', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(12,:), CompareResultsStd(12,:), 'kh--', 'linewidth', 2,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(13,:), CompareResultsStd(13,:), 'yh-', 'linewidth', 3,  'MarkerSize',ms); 
errorbar(m_num/K, CompareResults(14,:), CompareResultsStd(14,:), 'rp-', 'linewidth', 2,  'MarkerSize',ms);
ylabel('CPU Time (Second)'); xlabel('Sample Size');box on;
legend('OMP', 'Lasso', 'GroupLasso, gs=2','GroupLasso, gs=4','GroupLasso, gs=8','GroupLasso, gs=16','StructOMP');
axis([m_num(1)/K-0.5 m_num(end)/K+0.5 0 0.9])
textobj = findobj('type', 'text');
set(textobj, 'fontsize', ts);
h_xlabel = get(gca,'XLabel');
set(h_xlabel,'FontSize',ts); 
h_xlabel = get(gca,'YLabel');
set(h_xlabel,'FontSize',ts); 

