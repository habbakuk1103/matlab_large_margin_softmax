% large_margin_softmax.m

function [loss, dw, dx] = large_margin_softmax(x, w, label)
    % margin is 2
    % x:1024xn  w:1024x10
    outputdim = 10;
    batch_size = 20;
    dw = zeros(size(w));
    dx = zeros(size(x));
    
    xnorm = sqrt(sum(x.^2, 1)); % 1xn
    wnorm = sqrt(sum(w.^2, 1)); % 1x10
    theta = (w'*x)./(wnorm'*xnorm); % 10xn
    k = floor(theta.*2./pi); % 10xn
    
    f = (-1).^k.*2.*(w'*x).^2./(wnorm'*xnorm) - ...
        (2.*k+(-1).^k).*(wnorm'*xnorm); % 10xn
    
    s = sum(exp(w'*x), 1);
    s = repmat(s, outputdim, 1); % 10xn
    s = s - exp(w'*x);
    loss = exp(f)./(exp(f) + s); % 10xn
    loss = -log(loss).*label';
    loss = sum(loss(:)) ./ size(w, 2);
    
    %dl/df
    dldf = s./(f+s).^2;
    
    for ii = 1:outputdim
        for jj = 1:batch_size
            if label(jj, ii) == 0
                continue;
            end
            kk = k(ii, jj);
            xx = x(:, jj);
            ww = w(:, ii);  
            xxnorm = xnorm(jj);
            wwnorm = wnorm(ii);
            %df/dx
            tmp = (-1).^kk.*(4*ww'*xx.*ww./xxnorm./wwnorm - 2*(ww'*xx).^2.*xx./wwnorm./(xxnorm).^3) - ...
                    (2*kk+(-1).^kk).*(wwnorm./xxnorm.*xx);
            dx(:, jj) = dx(:, jj) + tmp.*dldf(ii, jj);
            %df/dw
            tmp = (-1).^kk.*(4*(ww'*xx).*ww./wwnorm./xxnorm - 2*(ww'*xx).^2.*ww./xxnorm./(wwnorm).^3) - ...
                    (2*kk+(-1).^kk).*(xxnorm./wwnorm.*ww);
            dw(:, ii) = tmp.*dldf(ii, jj);
        end
    end
    
    dx = dx./size(x, 2);
    dw = dw./size(x, 2);
    
end