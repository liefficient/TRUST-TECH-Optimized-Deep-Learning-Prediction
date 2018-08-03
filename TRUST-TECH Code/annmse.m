function y = annmse(all_weight)
all_price = evalin('base', 'all_price');
real_open=evalin('base', 'real_open');
    y=0;
    a1=0;
    a2=0;
    a3=0;
    a4=0;
    for i = 1:10
        a1 = all_price(i,1)*all_weight(1)+all_price(i,2)*all_weight(2)+all_price(i,3)*all_weight(3)+all_price(i,4)*all_weight(4)+all_weight(17);
        a2 = all_price(i,1)*all_weight(5)+all_price(i,2)*all_weight(6)+all_price(i,3)*all_weight(7)+all_price(i,4)*all_weight(8)+all_weight(18);
        a3 = all_price(i,1)*all_weight(9)+all_price(i,2)*all_weight(10)+all_price(i,3)*all_weight(11)+all_price(i,4)*all_weight(12)+all_weight(19);
        a4 = all_price(i,1)*all_weight(13)+all_price(i,2)*all_weight(14)+all_price(i,3)*all_weight(15)+all_price(i,4)*all_weight(16)+all_weight(20);
        y=(a1*all_weight(21)+a2*all_weight(22)+a3*all_weight(23)+a4*all_weight(24)+all_weight(25)-real_open(i))^2;
    end
    y=y*10^12;
end

