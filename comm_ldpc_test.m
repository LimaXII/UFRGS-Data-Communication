M = 4; % Modulation order (QPSK)
snr = [0.25,0.5,0.75,1.0,1.25];
numFrames = 10;
ldpcEncoder = comm.LDPCEncoder;
ldpcDecoder = comm.LDPCDecoder;
pskMod = comm.PSKModulator(M,'BitInput',true);
pskDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Approximate log-likelihood ratio');
pskuDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Hard decision');
errRate = zeros(1,length(snr));
uncErrRate = zeros(1,length(snr));

for ii = 1:length(snr)
    ttlErr = 0;
    ttlErrUnc = 0;
    pskDemod.Variance = 1/10^(snr(ii)/10);
    for counter = 1:numFrames
        data = logical(randi([0 1],32400,1));
        % Transmit and receive uncoded signal data
        mod_uncSig = step(pskMod, data); % Use step function
        rx_uncSig = awgn(mod_uncSig, snr(ii), 'measured');
        demod_uncSig = step(pskuDemod, rx_uncSig); % Use step function
        numErrUnc = biterr(data, demod_uncSig);
        ttlErrUnc = ttlErrUnc + numErrUnc;
        % Transmit and receive LDPC coded signal data
        encData = step(ldpcEncoder, data); % Use step function
        modSig = step(pskMod, encData); % Use step function
        rxSig = awgn(modSig, snr(ii), 'measured');
        demodSig = step(pskDemod, rxSig); % Use step function
        rxBits = step(ldpcDecoder, demodSig); % Use step function
        numErr = biterr(data, rxBits);
        ttlErr = ttlErr + numErr;
    end
    ttlBits = numFrames * length(rxBits);
    uncErrRate(ii) = ttlErrUnc / ttlBits;
    errRate(ii) = ttlErr / ttlBits;
end

plot(snr, uncErrRate, snr, errRate)
legend('Uncoded', 'LDPC coded')
xlabel('SNR (dB)')
ylabel('BER')
