function [d] = spm_kl_normal (m_q,c_q,m_p,c_p)
% Calculate the KL distance between two multivariate normal densities
% FORMAT [d] = spm_kl_normal (m_q,c_q,m_p,c_p)
%
% KL (Q||P) = <log Q/P> where avg is wrt Q
%
% between two Normal densities Q and P
%
% m_q, c_q    Mean and covariance of first Normal density
% m_p, c_p    Mean and covariance of second Normal density
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Will Penny 
% $Id: spm_kl_normal.m 807 2007-04-27 12:23:22Z will $

d=length(m_q);
m_q=m_q(:);
m_p=m_p(:);

Term1=0.5*spm_logdet(c_p)-0.5*spm_logdet(c_q);

inv_c_p=inv(c_p);
Term2=0.5*trace(inv_c_p*c_q)+0.5*(m_q-m_p)'*inv_c_p*(m_q-m_p);

d=Term1+Term2-0.5*d;



