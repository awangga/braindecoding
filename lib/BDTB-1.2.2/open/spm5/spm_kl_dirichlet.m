function [d] = spm_kl_dirichlet (lambda_q,lambda_p,log_tilde_pi)
% KL divergence between two Dirichlet densities
% FORMAT [d] = spm_kl_dirichlet (lambda_q,lambda_p,log_tilde_pi)
%
% Calculate KL (Q||P) = <log Q/P> where avg is wrt Q
% between two Dirichlet densities Q and P
%
% lambda_q      Parameter vector of first density
% lambda_p      Parameter vectpr of second density
% log_tilde_pi  <log (pi)> where avg is over Q. If this argument
%               isn't passed the routine will calculate it
%___________________________________________________________________________
% Copyright (C) 2007 Wellcome Department of Imaging Neuroscience

% Will Penny 
% $Id$

if nargin < 3
 m=length(lambda_q);
 lambda_tot=sum(lambda_q);
 dglt=spm_digamma(lambda_tot);
 for s=1:m,
   log_tilde_pi(s)=spm_digamma(lambda_q(s))-dglt;
 end
end


d=gammaln(sum(lambda_q));
d=d+sum((lambda_q-lambda_p).*log_tilde_pi);
d=d-sum(gammaln(lambda_q));
d=d-gammaln(sum(lambda_p));
d=d+sum(gammaln(lambda_p));




