% function dedirs_ge_20 gives DE_scheme with b0s if amount of b0s is given
% SuS April 2008 (copied from original tensor.dat file)

function DE_scheme = dedirs_ge_20(nob0s)

if nargin == 0
    DE_scheme = [-0.434938946482 0.685132899717 -0.584312435739;...
        -0.474060013098 0.860976920054 0.184352507755;...
        -0.829256490167 -0.550289985613 0.097542838019;...
        0.464421656080 0.422384590848 -0.778398216068;...
        0.240386556712 0.941384293978 -0.236664138397;...
        0.910939837519 -0.098176548471 -0.400686882429;...
        -0.185116778405 0.035545557996 -0.982073465510;...
        0.266800060066 -0.684012097813 0.678929435209;...
        0.339677264891 0.071129244772 0.937848594526;...
        0.347081475440 -0.527235773025 -0.775600985720;...
        -0.403753197462 0.355548772404 0.842952208598;...
        -0.410800740586 -0.675911546523 -0.611871173379;...
        0.268568798654 0.770374026033 0.578268674928;...
        -0.865131507158 0.028438831904 -0.500738163278;...
        0.884860772610 -0.185065380644 0.427518675596;...
        0.843316814297 0.529181929554 0.093718921021;...
        -0.464421687775 -0.422384607415 0.778398188168;...
        0.596562711719 -0.798812839696 -0.077530498020;...
        -0.938578491452 0.227080195093 0.259817244193;...
        -0.156558083055 -0.985288478562 0.068528684817];
elseif nargin == 1
    DE_scheme = [zeros(nob0s,3);...
        -0.434938946482 0.685132899717 -0.584312435739;...
        -0.474060013098 0.860976920054 0.184352507755;...
        -0.829256490167 -0.550289985613 0.097542838019;...
        0.464421656080 0.422384590848 -0.778398216068;...
        0.240386556712 0.941384293978 -0.236664138397;...
        0.910939837519 -0.098176548471 -0.400686882429;...
        -0.185116778405 0.035545557996 -0.982073465510;...
        0.266800060066 -0.684012097813 0.678929435209;...
        0.339677264891 0.071129244772 0.937848594526;...
        0.347081475440 -0.527235773025 -0.775600985720;...
        -0.403753197462 0.355548772404 0.842952208598;...
        -0.410800740586 -0.675911546523 -0.611871173379;...
        0.268568798654 0.770374026033 0.578268674928;...
        -0.865131507158 0.028438831904 -0.500738163278;...
        0.884860772610 -0.185065380644 0.427518675596;...
        0.843316814297 0.529181929554 0.093718921021;...
        -0.464421687775 -0.422384607415 0.778398188168;...
        0.596562711719 -0.798812839696 -0.077530498020;...
        -0.938578491452 0.227080195093 0.259817244193;...
        -0.156558083055 -0.985288478562 0.068528684817];
elseif nargin > 1
    disp('Error: too many input arguments');
end
DE_scheme = [DE_scheme(:,2) DE_scheme(:,1) -DE_scheme(:,3)];
