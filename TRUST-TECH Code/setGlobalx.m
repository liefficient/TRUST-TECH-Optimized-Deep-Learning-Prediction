function setGlobalx()
global all_price
global real_open
dataTable = readtable('TSLA_Test.csv', 'Format', '%q%f%f%f%f%f%f')
dataTable.Properties.VariableNames = {'Date', 'Open', 'High','Low','Close','Adj','Volume'};
dataTable(:,'Date') = [];
dataTable(:,'Volume') = [];
T=dataTable.Variables;
real_open=T(2:332,1);
all_price=T(1:331,1:4);
