function[ret] = isEqual(A, B)
ret = zeros(size(A));
if size(A) ~= size(B)
    throw 'A and B Not Equal Dimensions'
end

for cell = 1:numel(A)
    if abs(A(cell) - B(cell)) < 0.0001
        ret(cell) = 1;
    else
        ret(cell) = 0;
    end
end
end

        