K = 4;N = 8;
H1 =  [0 0 0 1 1 0 1 1;
    0 0 0 0 1 1 0 0
    1 1 0 0 0 0 0 1
    0 0 1 0 0 1 0 1];
H = sparse(H1);
hEnc = comm.LDPCEncoder(H);
hDec = comm.LDPCDecoder(H);
msg_source = logical(randi([0 1], K, 1));
msg_coded = step(hEnc, msg_source);  
LLR = double(msg_coded);

%Convert from logical to double where 0 goes to -1 and 1 goes to 1.
%LLR = 1 - double(msg_coded)*2;
msg_decoded = step(hDec,LLR);
errors = (sum(xor(msg_source,msg_decoded)));