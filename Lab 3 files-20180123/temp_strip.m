function [ frames ] = correct_strip( frames,filter_range)
frames=double(frames);
kernel = [-1,0,1;-2,0,2;-1,0,1];
 
for i = 1:size(frames,3)
    raw_frame = frames(:,:,i);
    fillter_frame = raw_frame;
    result_frame = raw_frame;
    
    for k = filter_range
        M = imfilter(fillter_frame,kernel,'replicate');
     
        map=abs(M)>50;
     
        for j = 1:size(raw_frame,1)
            raw = raw_frame(j,:);
            fill = medfilt1(raw,k);    
            fillter_frame(j,:) = fill;
        end
        
        diff=abs(raw_frame-fillter_frame);
        diff = diff>10;
        
        map=diff+map;
        map=map>1;
        
        imshow(map);
      
        result_frame(map)=fillter_frame(map);
     
    end
    
    frames(:,:,i)=uint8(result_frame);
end

end