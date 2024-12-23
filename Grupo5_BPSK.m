% Trabalho Final - Grupo 5
%
% Especifica��es:
%   5 BPSK, 16-QAM LDPC n = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema �completo� de comunica��o de dados, contendo, no m�nimo, 
%  os seguintes componentes: (1) Fonte de informa��o, 
%  (2) Codificador de canal, (3) Modula��o, (4) Ru�do,
%  (5) Demodula��o, (6) Decodificador de canal, (7) Receptor de informa��o  
%
% Objetivo:
%  1) Avaliar um sistema completo em termos de bit error rate (BER) e 
%  frame error rate (FER) variando par�metros do sistema
%  2) Avalia��o para um intervalo de Eb/N0
%  3) Analisar a efici�ncia de c�digos e modula��es
%  utilizadas no padr�o IEEE 802.11
%
% Luccas da Silva Lima - 00xxxxxx
% Matheus Almeida Silva - 00xxxxxx
% Thiago Leonel Rancan Bischoff - 00324856
% -------------------------------------------------------------------------

% Sem c�digo --------------------------------------------------------------

% Vari�veis
Nb = 8; % N�mero de bits enviados
EbNo = 10; % SNR (em dB)

% (1) Fonte de informa��o
sequencia_enviada = randi([0 1],1,Nb);

% (3) Modula��o
bpskMod = comm.BPSKModulator; % Configurar o modulador BPSK
modulatedSignal = step(bpskMod, sequencia_enviada.'); % Modula��o

% (4) Ru�do
noisySignal = awgn(modulatedSignal, EbNo, 'measured');

% (5) Demodula��o
bpskDemod = comm.BPSKDemodulator;
demodulatedData = step(bpskDemod, noisySignal);

% Exibir a sequ�ncia enviada, o sinal modulado, sinal com ru�do e sinal demodulado
figure('Name', 'BPSK Sem c�digo');
subplot(4,1,1); stairs(real(sequencia_enviada), 'LineWidth',2); axis([1 Nb -0.1 1.1]); title('Sinal Enviado');
subplot(4,1,2); stairs(real(modulatedSignal), 'LineWidth',2); axis([1 Nb -1.1 1.1]); title('Sinal Modulado');
subplot(4,1,3); stairs(real(noisySignal), 'LineWidth',2); title('Sinal com Ru�do');
subplot(4,1,4); stairs(real(demodulatedData), 'LineWidth',2); axis([1 Nb -0.1 1.1]); title('Sinal Demodulado');


% Com c�digo e decodifica��o hard -----------------------------------------


% Com c�digo e decodifica��o soft -----------------------------------------

