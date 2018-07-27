function [ frames ] = add_transition( frames,text,duration )
    position = [1 50];
    total_frame = size(frames,3);
    
    for k=total_frame-duration:total_frame
        trans_frame=insertText(frames(:,:,k),position,text);
       frames(:,:,k)=trans_frame(:,:,1);
    end
end

