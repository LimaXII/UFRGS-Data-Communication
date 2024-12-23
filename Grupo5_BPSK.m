% Trabalho Final - Grupo 5
%
% Especificações:
%   5 BPSK, 16-QAM LDPC n = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema “completo” de comunicação de dados, contendo, no mínimo, 
%  os seguintes componentes: (1) Fonte de informação, 
%  (2) Codificador de canal, (3) Modulação, (4) Ruído,
%  (5) Demodulação, (6) Decodificador de canal, (7) Receptor de informação  
%
% Objetivo:
%  1) Avaliar um sistema completo em termos de bit error rate (BER) e 
%  frame error rate (FER) variando parâmetros do sistema
%  2) Avaliação para um intervalo de Eb/N0
%  3) Analisar a eficiência de códigos e modulações
%  utilizadas no padrão IEEE 802.11
%
% Luccas da Silva Lima - 00xxxxxx
% Matheus Almeida Silva - 00xxxxxx
% Thiago Leonel Rancan Bischoff - 00324856
% -------------------------------------------------------------------------

% Sem código --------------------------------------------------------------

% Variáveis
Nb = 8; % Número de bits enviados
EbNo = 10; % SNR (em dB)

% (1) Fonte de informação
sequencia_enviada = randi([0 1],1,Nb);

% (3) Modulação
bpskMod = comm.BPSKModulator; % Configurar o modulador BPSK
modulatedSignal = step(bpskMod, sequencia_enviada.'); % Modulação

% (4) Ruído
noisySignal = awgn(modulatedSignal, EbNo, 'measured');

% (5) Demodulação
bpskDemod = comm.BPSKDemodulator;
demodulatedData = step(bpskDemod, noisySignal);

% Exibir a sequência enviada, o sinal modulado, sinal com ruído e sinal demodulado
figure('Name', 'BPSK Sem código');
subplot(4,1,1); stairs(real(sequencia_enviada), 'LineWidth',2); axis([1 Nb -0.1 1.1]); title('Sinal Enviado');
subplot(4,1,2); stairs(real(modulatedSignal), 'LineWidth',2); axis([1 Nb -1.1 1.1]); title('Sinal Modulado');
subplot(4,1,3); stairs(real(noisySignal), 'LineWidth',2); title('Sinal com Ruído');
subplot(4,1,4); stairs(real(demodulatedData), 'LineWidth',2); axis([1 Nb -0.1 1.1]); title('Sinal Demodulado');


% Com código e decodificação hard -----------------------------------------


% Com código e decodificação soft -----------------------------------------

