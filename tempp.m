 % Read the main image and template in grayscale
img = imread("C:\Users\LENOVO\OneDrive\Desktop\images.jpg");
template = imread("C:\Users\LENOVO\OneDrive\Desktop\images1.jpg");
if size(img, 3) == 3
    img = rgb2gray(img);
end
if size(template, 3) == 3
    template = rgb2gray(template);
end
% Resize template if larger than main image
if any(size(template) > size(img))
    scale=min(size(img)./size(template)) *0.9;
    template=imresize(template,scale);
    
end

[h, w] = size(template);
methods = {'normxcorr2', 'ssd', 'sad', 'correlation', 'normalized_correlation', 'normalized_difference'};
figure('Name', 'Template Matching: Heatmap | Score | Detected Match', 'NumberTitle', 'off');

for i = 1:6
    method = methods{i};
    img_copy = img;
    
    switch method
        case 'normxcorr2'
            % Normalized Cross-Correlation
            result = normxcorr2(template, img);
            [max_val, idx] = max(result(:));
            [ypeak, xpeak] = ind2sub(size(result), idx);
            top_left = [xpeak - w, ypeak - h];
            score = max_val;
            heatmap = result;
            
        otherwise
            % Manual sliding window methods
            result = zeros(size(img) - size(template) + 1);
            template_d = double(template);
            for y = 1:size(result,1)
                for x = 1:size(result,2)
                    patch = img(y:y+h-1, x:x+w-1);
                    patch_d = double(patch);
                    switch method
                        case 'ssd'
                            diff = patch_d - template_d;
                            result(y,x) = sum(diff(:).^2);
                        case 'sad'
                            diff = abs(patch_d - template_d);
                            result(y,x) = sum(diff(:));
                        case 'correlation'
                            result(y,x) = sum(patch_d(:) .* template_d(:));
                        case 'normalized_correlation'
                            patch_norm = (patch_d - mean(patch_d(:))) / std(patch_d(:));
                            template_norm = (template_d - mean(template_d(:))) / std(template_d(:));
                            result(y,x) = sum(patch_norm(:) .* template_norm(:));
                        case 'normalized_difference'
                            diff = patch_d - template_d;
                            result(y,x) = sum(diff(:).^2) / sum(template_d(:).^2);
                    end
                end
            end
            if ismember(method, {'ssd', 'sad', 'normalized_difference'})
                [score, idx] = min(result(:));
            else
                [score, idx] = max(result(:));
            end
            [y, x] = ind2sub(size(result), idx);
            top_left = [x, y];
            heatmap = result;
    end
    bottom_right = top_left + [w - 1, h - 1];
    % Heatmap subplot
    subplot(2,9, (i-1)*3 + 1);
    imagesc(heatmap); colormap gray;
    title('Matching Heatmap'); axis off;
    % Score subplot
    subplot(2,9, (i-1)*3 + 2);
    text(0.5, 0.5, {method, sprintf('Score: %.4f', score)}, ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'BackgroundColor', 'yellow');
    axis off;
    % Detected Match subplot
    subplot(2,9, (i-1)*3 + 3);
    imshow(img_copy); hold on;
    rectangle('Position', [top_left(1), top_left(2), w, h], 'EdgeColor', 'r', 'LineWidth', 2);
    title('Detected Match'); hold off;
end