clc;
clear;
close all;

% SumV = @(x1,x2) test(x1,x2); 
readtestcsv;
loadweights;
Func = @annmse; 
x = sym('x', [1,25])

f = Func(x)
x_derive = symvar(f)
G = gradient(f,x)
J = jacobian(G,x)
    

inits = rot90(all_weight);
inits_val=0;
oldinits = rot90(all_weight);
[inits,inits_val] = fmincon(Func,inits,[],[])
min_val=inits_val;
result = [];
result = [result;inits];
lastresult = [];
lastresult = [lastresult;inits];
figure;
tier = 0;
while(size(lastresult,1)~=0 && tier == 0)
    if(tier == 1)
        break;
    end
    newresult = [];
    for count_solution = 1:size(lastresult,1)
        points = lastresult(count_solution,:)
        %plot(points(1),points(2),'r*')
        %pause(0.05);
        %hold on;
        J_value = double(subs(J,x_derive,points));
        [dire,eV] = eig(J_value);
       % orth = [[1,0];[0,1]];
        % way = [dire(1,:);dire(2,:);-dire(1,:);-dire(2,:)];
        way = [dire;-dire];
        for direIndex = 1:length(way)
            preV = double(subs(f,x_derive,points));
            step_size=0;
            a=0;
            for i=1:length(inits)
                a=a+(inits(i)-oldinits(i))^2;
            end
            step_size=sqrt(a);
            move = 10^-2*step_size*way(direIndex,:); 
            newpoints=zeros(1,5);
            for z=1:length(move)
                newpoints(z)=points(z)+move(z);
            end
            %newV = double(subs(f,x_derive,newpoints));
            newV=Func(newpoints);
            loop = 0;
            while((newV>preV)&&(loop <1000))
                preV = newV;
                for z=1:length(move)
                    newpoints(z)=newpoints(z)+move(z);
                end
                %newV = double(subs(f,x_derive,newpoints));
                newV=Func(newpoints);
                %h1 = plot(newpoints(1),newpoints(2),'--gs');
                %pause(0.01);
               % delete(h1);
                loop = loop+1;
            end
            if(newV<preV)
                %plot(newpoints(1),newpoints(2),'b*');
                for z=1:length(move)
                    newpoints(z)=newpoints(z)+5*move(z);
                end
                [x,fval] = fmincon(Func,newpoints,[],[]);
                if(fval<min_val)
                    min_val=fval
                end
                newpoints = x;
                record = 1;
                for check_exist = 1:size(result,1)
                   cur=true(1)
                   for index=1:25
                        cur=cur&&((abs(newpoints(index))<1.05*abs(result(check_exist,index)))&&(abs(newpoints(index))>0.95*abs(result(check_exist,index))));
                   end
                   if (cur==1)
                       nextcur=true(1)
                       for nextindex=1:25 
                           nextcur=nextcur&&(sign(newpoints(nextindex))==sign(result(check_exist,nextindex)));
                       end  
                       if(nextcur==1)
                           record=0;
                       end
                   end
                end
                if(record == 1)
                   % plot(newpoints(1),newpoints(2),'r*');
                    newresult = [newresult;newpoints];
                    result = [result;newpoints];
                end
                
            end
        end
    end
    lastresult = [];
    lastresult = newresult;
    tier=tier+1;
end
