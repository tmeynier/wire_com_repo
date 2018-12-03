% Returns a vector with randomly -1 and 1 values

function y = create_random_preambule(pre_lgh)
    
    result = zeros(1,pre_lgh);

    for i = 1 : pre_lgh
        if randn() > 0 
            result(i) = 1;
        else
            result(i) = -1;
        end
    end 
    
    y = transpose(result);
end 