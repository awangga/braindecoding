function [slice] = spm_vb_robust (Y,slice)
% Robust GLM modelling in a slice of fMRI
% FORMAT [slice] = spm_vb_robust (Y,slice)
%
% Y     -  [T x N] time series with T time points, N voxels
%
% slice -  data structure containing fields described in spm_vb_glmar.m
%
%_______________________________________________________________________
% Copyright (C) 2007 Wellcome Department of Imaging Neuroscience

% Will Penny 
% $Id$

[T,Nv]=size(Y);
X=slice.X;
k=slice.k;

for i=1:Nv,
    disp(sprintf('Analysing voxel %d out of %d',i,Nv));
    yv=Y(:,i);
    if sum(diff(yv).^2) > 0
        rglm1=spm_rglm(yv,X,1);
        rglm2=spm_rglm(yv,X,2);
        logbf21=rglm2.fm-rglm1.fm;
        w=rglm2.posts.w_mean;
        lambda=1/rglm1.variances;
        w_dev=sqrt(diag(rglm2.posts.w_cov));
        w_cov=rglm2.posts.w_cov;
        
        gamma=rglm2.posts.gamma(2,:)';
    else
        w=zeros(k,1);
        w_dev=w;
        w_cov=eye(k,k);
        lambda=0;
        logbf21=0;
        gamma=zeros(T,1);
    end
    
    % Save to slice structure
    slice.wk_mean(:,i)=w;
    slice.w_dev(:,i)=w_dev;
    slice.w_cov{i}=w_cov;
    slice.mean_lambda(i)=lambda;
    slice.F(i)=logbf21;
    slice.gamma(:,i)=gamma;
    slice.b(:,i)=rglm2.mean_alpha*ones(slice.k,1);
end

slice.N=Nv;