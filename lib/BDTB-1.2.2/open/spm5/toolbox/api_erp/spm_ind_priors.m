function [pE,gE,pC,gC] = spm_ind_priors(A,B,C,Nf)
% prior moments for a neural-mass model of erps
% FORMAT [pE,gE,pC,gC] = spm_ind_priors(A,B,C,dipfit,Nu,Nf)
% A{2},B{m},C  - binary constraints on extrinsic connections
% Nf           - number of frequencies

%
% pE - prior expectation - f(x,u,P,M)
% gE - prior expectation - g(x,u,G,M)
%
% spatial parameters
%--------------------------------------------------------------------------
% or gE.L    - coeficients of local modes - ECD
%
% connectivity parameters
%--------------------------------------------------------------------------
%    pE.A    - trial-invariant
%    pE.B{m} - trial-dependent
%    pE.C    - stimulus-stimulus dependent
%
%    p.K     - global rate [coupling] constant
%
% stimulus and noise parameters
%--------------------------------------------------------------------------
%    pE.R - magnitude, onset and dispersion
%    pE.N - background fluctuations
%
% pC - prior covariances: cov(spm_vec(pE))
%__________________________________________________________________________
%
% David O, Friston KJ (2003) A neural mass model for MEG/EEG: coupling and
% neuronal dynamics. NeuroImage 20: 1743-1755
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_ind_priors.m 1040 2007-12-21 20:28:30Z karl $

% orders
%--------------------------------------------------------------------------
n    = size(C,1);                                 % number of sources
nu   = size(C,2);                                 % number of inputs
n1   = ones(n,1);

% paramters for electromagnetic forward model
%--------------------------------------------------------------------------
G.L  = sparse(1,n);  U.L  = ones(1,n)/32;

% Global scaling
%--------------------------------------------------------------------------
E.K  = 0;
V.K  = 1/4;

% set extrinsic connectivity - linear and nonlinear (cross-frequency)
%--------------------------------------------------------------------------
E.A  = kron(speye(Nf,Nf), -speye(n,n));
V.A  = kron(speye(Nf,Nf),A{1}) + kron(1 - speye(Nf,Nf),A{2});

% input-dependent
%--------------------------------------------------------------------------
for i = 1:length(B)
    E.B{i} = sparse(n*Nf,n*Nf);
    V.B{1} = kron(ones(Nf,Nf),B{i}) & V.A;
end

% exognenous inputs
%--------------------------------------------------------------------------
E.C  = kron(ones(Nf,1),C - C);
V.C  = kron(ones(Nf,1),C);

% set stimulus parameters: magnitude, onset and dispersion
%--------------------------------------------------------------------------
E.R  = kron(ones(nu,1),[0 0]);
V.R  = kron(ones(nu,1),[1/16 1/16]);

% prior momments
%--------------------------------------------------------------------------
pE = E;
gE = G;
pC = diag(sparse(spm_vec(V)));
gC = diag(sparse(spm_vec(U)));
  
