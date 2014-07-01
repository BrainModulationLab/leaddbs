function [numidpoint,diam,greyobj,options]=ea_findonemidpoint(slicebw,estpoint,mask,options)

stats=regionprops(slicebw,'Centroid','EquivDiameter');

CC=bwconncomp(slicebw);


if CC.NumObjects==0
    numidpoint=[nan,nan];
    diam=nan;
else
numidpoint=stats.Centroid;
distance=pdist([estpoint;numidpoint]);
diam=stats.EquivDiameter;
end


if CC.NumObjects>1
    
    ea_showdis(['Number of objects: ',num2str(CC.NumObjects),'.'],options.verbose);
    for obj=1:CC.NumObjects

        slicebwobj=slicebw;
        slicebwobj(:)=0;
        slicebwobj(CC.PixelIdxList{obj})=1; % isolate object
        
        stats=regionprops(slicebwobj,'Centroid','EquivDiameter');
        objdistance=pdist([estpoint;stats.Centroid]);
        
        ea_showdis(['Distance to object ',num2str(obj),': ',num2str(objdistance),'.'],options.verbose);
        
        if objdistance<distance % if isolated object performs better
            ea_showdis(['This is better. Using this object.'],options.verbose);
            greyobj=slicebwobj;
            greyobj=greyobj(logical(mask));
            greyobj=reshape(greyobj,sqrt(length(greyobj)),sqrt(length(greyobj)));

            numidpoint=stats.Centroid;
            distance=objdistance;
            diam=stats.EquivDiameter;
        end
        
        
    end
    
end

if ~exist('greyobj','var')
    greyobj=nan;
end


if ~isnan(estpoint)
if options.automask % if maskwindow size is set to 'auto'
    
    if CC.NumObjects>1
        if options.maskwindow>6 % if more than two objects present and size not too small already, decrease by two.
            
            options.maskwindow=options.maskwindow-2;
        end
    else
        if length(CC.PixelIdxList)/((2*options.maskwindow+1)^2)>0.001 % if the object found does fill out more than 0.001 of pixel-space, increase mask.
                options.maskwindow=options.maskwindow+1;
        else
            if options.maskwindow>4
                
                options.maskwindow=options.maskwindow-1;
            end
        end
    end
    
    
end
    
end