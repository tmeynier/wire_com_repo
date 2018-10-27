% Tool function: take a signal bit and modulate it according to the
% constellation scheme (QAM or PSK)

function y = modulation(bit_signal, isQAM, M, Ex, d) 

    b = log2(M);
    % Set the table of bit-to-symbol mapper
    bit2decvec = 2.^[b-1:-1:0]'; % Helps to convert bits to symbol index (0,1,...M-1). LSB is the rightmost or bottommost bit
    % Obtain bit representation of each of the M symbols
    temp1 = dec2bin([0:M-1]); % binary strings representing 0,1,...,M-1
    modbits = [];
    for (ii=1:b)
        modbits(ii,:) = str2num(temp1(:,ii))'; 
    end 
    % modbits are the b bits represented by each modulation symbol from 0,1,...M-1
    % LSB is the rightmost or bottommost bit

    if (isQAM)
        % QAM modulation symbols
        if (rem(b,2)==0)
            % Square-QAM
            bit2decvecSQ = 2.^[b/2-1:-1:0]'; % Helps for SQ-QAM only
            for (kk=0:M-1)
                xI = (modbits(1:b/2,kk+1)'*bit2decvecSQ-sqrt(M)/2+1/2)*d;
                xQ = (modbits(b/2+1:b,kk+1)'*bit2decvecSQ-sqrt(M)/2+1/2)*d;           
                modsymbols(kk+1) = xI+j*xQ;
            end
        else
            % Cross-QAM
            bit2decvecCRin = 2.^[(b-1)/2-1:-1:0]'; % Helps for Cross-QAM Square-positioned points only
            bit2decvecCRside2 = 2.^[b-(4+(b-1)/2):-1:0]'; % Helps for Cross-QAM Side-positioned points only
            for (kk=0:M/2-1)
                % Symbols in the square part of Cross-QAM
                xI = (modbits(2:(b+1)/2,kk+1)'*bit2decvecCRin-sqrt(M/2)/2+1/2)*d;
                xQ = (modbits((b+3)/2:b,kk+1)'*bit2decvecCRin-sqrt(M/2)/2+1/2)*d;           
                modsymbols(kk+1) = xI+j*xQ;
            end
            for (kk=M/2:M-1)
                % Symbols in the side part of Cross-QAM
                % Choose one out of 4 sides, using 2 bits
                sideindex = modbits(2:3,kk+1)'*2.^[1,0]';
                if (M==8)
                    % 8-QAM is special
                   modsymbols(kk+1) = (1.5*d - j*d/2); % There is only one side point, per side
                else
                   xI = (modbits(4:3+(b-1)/2,kk+1)'*bit2decvecCRin-sqrt(M/2)/2+1/2)*d;
                   xQ = (modbits(4+(b-1)/2:b,kk+1)'*bit2decvecCRside2+sqrt(M/2)/2+1/2)*d;
                   modsymbols(kk+1) = xI+j*xQ;
                end
                modsymbols(kk+1) = modsymbols(kk+1)*exp(j*pi/2*sideindex); % Rotate it to the correct side
            end
        end
    else
        % PSK modulation symbols
        modsymbols = sqrt(Ex)*exp(j*(2*pi/M*[0:M-1])); % PSK constellation symbols. Symbols of index from 0,1,...,M-1
    end
    
    % Generate symbols for transmission
    symbolindex  = reshape(bit_signal,b,[])'*bit2decvec; % Symbol index from 0 to M-1
    y = transpose(modsymbols(symbolindex+1)) ; % Modulation of bits
end