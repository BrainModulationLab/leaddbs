% function dedirs_ge_9 gives DE_scheme with b0s if amount of b0s is given
% SuS April 2008 (copied from original tensor.dat file)

function DE_scheme = dedirs_ge_9(nob0s)

if nargin == 0
    DE_scheme = [0.914109572223 -0.182781178690 -0.361931942064;...
        0.293329304506 0.734642489361 -0.611766566546;...
        -0.480176899428 -0.046026929940 0.875963279468;...
        -0.705684904851 0.704780196051 -0.072757750931;...
        0.370605109670 0.769162968265 0.520615194684;...
        -0.904030464226 -0.412626217894 -0.111662545460;...
        -0.162180419233 -0.247163999394 -0.955304908927;...
        0.063327560246 -0.997971078243 -0.006583851785;...
        0.610701141906 -0.322016246902 0.723429092590];
elseif nargin == 1
    DE_scheme = [zeros(nob0s,3);...
        0.914109572223 -0.182781178690 -0.361931942064;...
        0.293329304506 0.734642489361 -0.611766566546;...
        -0.480176899428 -0.046026929940 0.875963279468;...
        -0.705684904851 0.704780196051 -0.072757750931;...
        0.370605109670 0.769162968265 0.520615194684;...
        -0.904030464226 -0.412626217894 -0.111662545460;...
        -0.162180419233 -0.247163999394 -0.955304908927;...
        0.063327560246 -0.997971078243 -0.006583851785;...
        0.610701141906 -0.322016246902 0.723429092590];
elseif nargin > 1
    disp('Error: too many input arguments');
end
DE_scheme = [DE_scheme(:,2) DE_scheme(:,1) -DE_scheme(:,3)];
