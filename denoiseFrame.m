function [xpos, ypos] = denoiseFrame(currentFrame)
    
    % estimate a terrible threshold value using the image mean
    m   = mean(currentFrame(:));
    
    % create a binary mask...
    % white pixels are above the threshold value of m
    msk = currentFrame > m; 
    
    % analyze the binary image and extract the area and centroid info
    rp = regionprops(msk,'Area','Centroid');
    
    % collect a list of all region areas
    areas=[rp.Area];
    
    % find the biggest one. This should be the particle region
    index = areas==max(areas);
    
    % Use the index to get the particle centroid
    cnt = rp(index).Centroid;
    
    % set the x and y position as outputs
    xpos = cnt(1);
    ypos = cnt(2);

end

function out = convolutionFunc(in)

    % create a filter
    kernel = ones(5);
    
    % normalize the filter to make it act as a moving average
    kernel = kernel/sum(kernel(:));
    
    % apply the filter
    out = conv2(in, kernel, 'same');

end

function out = fftFunc(in)

    f = fft2(in);

    % create a disk to filter out noise in the frequency space

    % apply the disk

    % return the less noisy image
    out = abs(ifft2(f));

end

function z = expmaxFunc(in)

    in = double(in);
    % this is the expectation maximization algorithm for 2 gaussians
    % sort data for smooth graphs
    [x,ind]   = sort(in(:));
    [~,ind]   = sort(ind);

    % initial guesses
    u1      = min(x);
    u2      = max(x);
    sig1    = std(x);
    sig2    = std(x);
    pih     = 0.1;
    limit   = 1;

    while limit>0.0001

        % get responsibilities
        gammai  = pih*dens(x,u2,sig2)./...
            ((1-pih)*dens(x,u1,sig1)+pih*dens(x,u2,sig2));

        % maximization step: weighted means/variances
        u1      = sum((1-gammai).*x)/sum(1-gammai);
        u2      = sum(gammai.*x)/sum(gammai);
        sig1    = sqrt( sum((1-gammai).*(x-u1).^2)/sum(1-gammai));
        sig2    = sqrt( sum(gammai.*(x-u2).^2)/sum(gammai));

        % convergence condition
        pihtemp = sum(gammai)/numel(gammai);
        limit   = abs(pih-pihtemp);
        pih     = pihtemp;

        % you can comment the next 5 lines to make it run faster

        % d1      = dens(x,u1,sig1);
        % d2      = dens(x,u2,sig2);
        % plot(x,d1/max(d1),x,d2/max(d2))
        % hold on,plot(x,gammai,'black:'),hold off
        % pause(0.2)
    end

        z       = zeros(size(in));
        z(:)    = gammai(ind);

end

function out = dens(y,u,sig)
    
    % gaussian density function - can be any normalized distribution
    out = exp( -(y - u).^2/(2*sig^2) ) /(sqrt(2*pi)*sig);
    
end