function [a] = spm_uncat(x,a)
% converts a matrix into an array
% FORMAT [a] = spm_uncat(x,a);
% x - matrix
% a - cell array
%
% i.e. a = spm_uncat(spm_cat(a),a)
%
% see also spm_vec and spm_unvec
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_uncat.m 258 2005-10-18 18:21:07Z karl $

% fill in varargout
%--------------------------------------------------------------------------
[p q] = size(a);
for i = 1:p
    for j = 1:q
          m(i,j)  = size(a{i,j},1);
          n(i,j)  = size(a{i,j},2);
    end
end
m     = max(m',[],1);
n     = max(n ,[],1);
for i = find(m)
    y     = x(1:m(i),:);
    x     = x((m(i) + 1):end,:);
    for j = 1:q
        a{i,j} = y(:,1:n(j));
        y      = y(:,(n(j) + 1):end);
    end
end
