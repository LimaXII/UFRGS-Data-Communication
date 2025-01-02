clear;
close;
num_b = 1000000; %número de bits a serem simulados
bits = complex(2*randi(2, 1, num_b)-3, 0); %bits aleatórios modulados em BPSK (parte real em 1 e -1)
Eb_N0_dB = 0:1:9; %faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); %faixa de Eb/N0 linearizada
ber = zeros(size(Eb_N0_lin)); %pré-alocação do vetor de BER
Eb = 1; % energia por bit para a modulação BPSK utilizada

NP = Eb ./ (Eb_N0_lin); %vetor de potências do ruído
NA = sqrt(NP); %vetor de amplitudes do ruído
    
for i = 1:length(Eb_N0_lin)
    n = NA(i)*complex(randn(1, num_b), randn(1, num_b))*sqrt(0.5); %vetor de ruído complexo com desvio padrão igual a uma posição do vetor NA
    r = bits + n; % vetor recebido
    demod = sign(real(r)); % recupera a informação (sinal da parte real)
    ber(i) = sum(bits ~= demod) / num_b; % contagem de erros e cálculo do BER
end

ber_theoretical = 0.5*erfc(sqrt(2*Eb_N0_lin)/sqrt(2)); %BER teórico para comparação
semilogy(Eb_N0_dB, ber, 'x', Eb_N0_dB, ber_theoretical, 'r', 'LineWidth', 2, 'MarkerSize', 10);
xlabel('Eb/N0 (dB)');
ylabel('BER');
legend('Simulado','Teórico');