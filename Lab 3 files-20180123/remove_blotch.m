function [ result ] = remove_blotch(frames,grow_threshold,threshold)
frames = double(frames);
result = frames;

total_frames = size(frames,3);
% horizontal sobel kernel for estimate G_x
sobel_kernel = [1,2,1;0,0,0;-1,-2,-1];

for i = 4:total_frames-1
    
    last_frame = frames(:,:,i-1);
    current_frame = frames(:,:,i);
    next_frame = frames(:,:,i+1);
    
    % compute the approximation of gradient magnitude of current and
    % adjcent frames.
    M1 = compute_map(last_frame,sobel_kernel,threshold);
    M2 = compute_map(current_frame,sobel_kernel,threshold);
    M3 = compute_map(next_frame,sobel_kernel,threshold);
    
    % keep the differences features in the adjcent frames.
    M = (M2~=M1)|(M2~=M3);
    
    % obtain the indecies of the starting positions
    inds = find(M);
    
    % uses each position as seed to apply region growing
    M=grow_mask(uint8(current_frame),inds,grow_threshold);
    
    result_frame=current_frame;
    % uses average of last three frame as reference to copy the pixel
    % covered by the blotch over.
    sum_frame = result(:,:,i-3:i-1);
    average_frame = sum(sum_frame,3)/3;
    
    result_frame(M)=average_frame(M);
    
    result(:,:,i)=result_frame;

end

result=uint8(result);

end

%%=========================================================================
function map = compute_map(frame,kernel,threshold)
    % apply horizontal sobel kernel to compute the manitude of the gradient
    gy = imfilter(frame,kernel,'replicate');
    gx = imfilter(frame,kernel','replicate');
    G = sqrt(gy.^2+gx.^2);
    % kept the response that is larger than the given thereshold
    map = G>threshold;
end

%%=========================================================================
function Mask=regionGrow(I,T,x,y)

[M,N]=size(I);
Mask=zeros(M,N);
max_count = 800;

if isinteger(I)
    I=im2double(I);
end

% seed intentsity
seed=I(x,y);
Mask(x,y)=1;

total_intensity=seed;

total_count=1;
count=1;

threshold = T;

% when no more pixel get labeled, terminate and return the mask
while count>0
    I_sum=0;
    count=0;
    for i=1:M
        for j=1:N
            
            if Mask(i,j)==1
                % it's not on the boarder
                if (i-1)>0&&(i+1)<(M+1)&&(j-1)>0&&(j+1)<(N+1)
                    % loop though the neighborhood to find connected pixels
                    for u=-1:1
                        for v=-1:1
                            % if the neighbor pixel is not labeled, and the
                            % difference is smaller than the threshold then
                            % included in the mask.
                            if Mask(i+u,j+v)==0 && abs(I(i+u,j+v)-seed) <= threshold 
                                Mask(i+u,j+v)=1;
                                % upate the guidences values
                                count=count+1;
                                I_sum=I_sum+I(i+u,j+v);
                            end
                            
                        end
                    end
                    
                end
            end
            
        end
    end
    total_count = total_count+count;
    
    % if the blotch region has too many pixel, then it's not likely to be
    % the noise blotch
    if total_count>max_count
        count=-1;
        Mask=zeros(M,N);
    end
    
    total_intensity = total_intensity+I_sum;
    % update the seed value as the average intensity of all labeled pixels
    seed = total_intensity/total_count;
end
end
%%=========================================================================
function Mask=grow_mask(frame,inds,T)
    frame_size = size(frame);
    Mask = zeros(frame_size);
    
    for i=1:length(inds)
        % if this pixel have not been inclcued in the mask
        if Mask(inds(i))==0
          % get the coordinate of the pixel
          [x,y] = ind2sub(frame_size,inds(i));
          % uses this coordinate as seed for region growing
          temp_mask = regionGrow(frame,T,x,y);
          % Add the mask reuslt
          Mask = Mask+temp_mask;
        end
        
    end
    
    Mask=Mask>0;
end


