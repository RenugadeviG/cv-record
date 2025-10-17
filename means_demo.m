function kmeans_demo
    n = 5; sz = 512;                 % clusters, image size
    col = uint8(hsv2rgb([(0:1/n:1-1/n)' ones(n,2)])*255);
    while true
        [pts,~] = gauss_pts(n,sz);   % sample Gaussian points
        [lab,~] = kmeans(single(pts),n,'Options',statset('MaxIter',100));

        img = zeros(sz,sz,3,'uint8');
        for i = 1:size(pts,1)
            x = round(pts(i,1)); y = round(pts(i,2));
            if x>=1 && x<=sz && y>=1 && y<=sz, img(y,x,:) = col(lab(i),:); end
        end
        imshow(img);
        if waitforbuttonpress==2, break; 
        end
    end
end
function [pts,lab] = gauss_pts(n,sz)
    pts=[]; lab=[];
    for i=1:n
        c = randi([sz*.25 sz*.75],1,2);  % center
        s = randi([10 40]);              % spread
        m = 200;               % points count
        pts=[pts; randn(m,2)*s + c];     
        lab=[lab; i*ones(m,1)];
    end
end
