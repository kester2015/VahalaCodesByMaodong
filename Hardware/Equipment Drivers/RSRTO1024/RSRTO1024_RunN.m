function RSRTO1024_RunN(RTO,N)
% Acquire data
% Jose Jaramillo, 5-Oct-15 Standarized Names

fprintf(RTO,['ACQuire:COUNt ', num2str(N)]);            %Set the data format to Real
fprintf(RTO,'RUNSingle');
