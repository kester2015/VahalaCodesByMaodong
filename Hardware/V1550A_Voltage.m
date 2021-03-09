function voltage=V1550A_Voltage(transmission)

interp_table=[4.3682 3.8158 3.6663 3.5775 3.5069 3.4479 3.3995 3.3574 3.3198 3.2843 ...
              3.2548 3.2245 3.1962 3.1708 3.1458 3.1226 3.0986 3.0780 3.0567 3.0375 ...
              3.0173 2.9975 2.9785 2.9615 2.9432 2.9259 2.9084 2.8923 2.8754 2.8599 ...
              2.8441 2.8288 2.8129 2.7976 2.7830 2.7680 2.7532 2.7385 2.7243 2.7098 ...
              2.6958 2.6809 2.6669 2.6521 2.6384 2.6238 2.6096 2.5963 2.5820 2.5680 ...
              2.5529 2.5389 2.5249 2.5104 2.4968 2.4821 2.4680 2.4534 2.4386 2.4245 ...
              2.4096 2.3944 2.3801 2.3657 2.3502 2.3352 2.3200 2.3040 2.2880 2.2723 ...
              2.2559 2.2406 2.2235 2.2061 2.1900 2.1725 2.1554 2.1369 2.1178 2.0987 ...
              2.0787 2.0587 2.0370 2.0154 1.9924 1.9700 1.9464 1.9189 1.8915 1.8632 ...
              1.8334 1.8010 1.7655 1.7271 1.6827 1.6369 1.5849 1.5178 1.4391 1.3204 ...
              1.1102];
if transmission<=0
    voltage=interp_table(1);
elseif transmission>=1
    voltage=interp_table(end);
else
    voltage=interp1(linspace(0,1,101),interp_table,transmission);
end
voltage=round(1000*voltage)/1000;
end