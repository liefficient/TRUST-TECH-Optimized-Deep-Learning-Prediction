% Code is meant to be read.  (making functions helps!)

% Kevin Chang



% Reset everything.

clear;clc;close all;


rng(0)

setGlobalfirst(999e16)

Func = @Schwefel_213_kev;

dim = 100;                            % dimensionality of the problem

num_particles = 10000;                % number of particles for PSO

MaxIter = 20;                          % maxiter for pso

tiers = 1;

display('bob')

[swarm,gbest_i] = PSO_kev(Func,dim,num_particles,MaxIter);



display('best values for x')

for i = 1:size(swarm(gbest_i,3,:),3)

    X(i) = swarm(gbest_i,3,i);

end

X

display('objective function value:')

X_obj = swarm(gbest_i,4,1);

X_obj



%% known optimal location + obj fcn value

best = getGlobalfirst()    % returns the best possible value of the problem

% ^this was initialized in schwefel213

best_obj_fcn_value = Func(best.')







%% get the swarm data into one big matrix so you can use ISODATA on it.  

swarm_matrix = zeros(num_particles,0);

for i = 1:dim

    swarm_matrix = horzcat(swarm_matrix,swarm(:,1,i));

    

end







%% ISODATA: input points, return the best point from each cluster.

% This function implements N-D ISODATA algorithm 

% INPUTS: 

% X : 2D Nxp array. N observations, p-dimention. 

% k : maximum number of clusters 

% OC : threshold of distance for cluster merging 

% OS : threshold of standard deviation for cluster splitting 

% L : maximum number of clusters that can be merged at one time 

% I : maximum number of iterations 

% ON : threshold of number of samples for cluster elimination 

% NO : Extra Parameter to automatically answer no to 

% the request to change any parameters 

% min_dist : minimum distance between a sample and each cluster center. If 

% you don't want to eliminate any sample, give it a high value 

% 

% OUTPUTS: 

% A : number of cluster 

% Z : 1xA vector. Centers for each cluster. 

% Xcluster : 1xA cell. Observations in each cluster 

% cluster : 1xN vector. Cluster labels for each observation

k = 10;

OC = 10;

OS = 1e-10;

L = 2;

I = 50;

ON = 5;



NO = true;

min_dist = 1e10;

[Z, Xcluster, A, cluster] = wfIsodata_ND(swarm_matrix, k, L, I, ON, OC, OS, NO, min_dist);

fprintf('number of clusters found: %i',A)

swarm_matrix = horzcat(cluster.',swarm_matrix);



% find the best point from each cluster

smallest_x_matrix_approx = zeros(0,dim);

for i = 1:A

    indices_in_cluster_vector= (swarm_matrix(:,1) == i);

    cluster = swarm_matrix(indices_in_cluster_vector,2:end);

    obj_values_in_cluster = swarm(indices_in_cluster_vector,4,1);

    [~,cluster_index_of_smallest_obj] = min(obj_values_in_cluster);

    smallest_x_matrix_approx = vertcat(smallest_x_matrix_approx,cluster(cluster_index_of_smallest_obj,:));

end

smallest_x_matrix_approx = smallest_x_matrix_approx.';   % making each x into column form instead



% get the gradient system:

x = sym('x',[dim,1]);



setGlobalfirst(999e16)

Func = @Schwefel_213_kev;

f = Func(x);

d_x = gradient(f,x);

x_derive = symvar(f);

% get the jacobian

J_x = jacobian(d_x,x);



% alpha = 0.5;

% c = 0.5;

% tol_dx = 1e-4;

% t_init = 10;

% max_it = 200;

%% take the best point from each cluster & run newton to find local min

smallest_x_matrix_exact = zeros(dim,0);

for i = 1:A

    x_k = smallest_x_matrix_approx(:,i);

%     x_newton = newton(x_k,d_x,J_x,x_derive,dim);

    lb = -pi*ones(size(x_k,1),1);

    ub = pi*ones(size(x_k,1),1);

    x_newton = fmincon(Func,x_k,[],[],[],[],lb,ub)

    Func(x_newton)

    smallest_x_matrix_exact = horzcat(smallest_x_matrix_exact,x_newton)

    % symvar(d_x)

end





%% compute 1 tier of solutions.  

total_tiers = 0;

i = 1;

old_soln_bank = smallest_x_matrix_exact;

new_soln_bank = old_soln_bank

new_solutions_added = size(old_soln_bank,2)

while(i <= tiers)

    total_tiers = total_tiers + 1;

    fprintf('working on tier %d now',total_tiers)

    

    

    % at each local minimum, take the jacobian matrix and find the

    % eigenvectors.

    for j = (size(old_soln_bank,2) - (new_solutions_added-1)):size(old_soln_bank,2)         % loop through each new soln in soln bank

        curr_soln = old_soln_bank(:,j);

        [directions_bank,~] = eig(double(subs(J_x,x_derive.',curr_soln  )));

        

        

        for k = 1:dim   % loop through each eigenvector.  

            curr_vector = directions_bank(:,k);

            curr_pos = curr_soln;

            while(1)    % go in the direction of the eigenvector until...

                pre_obj_val = Func(curr_pos);

                curr_pos = curr_pos + (1e-3)*curr_vector/norm(curr_vector);

                post_obj_val = Func(curr_pos);

                if post_obj_val < pre_obj_val

                    % integrate for a certain amount of time, then put it

                    % into newton!

                    for ll = 1:20

                        df_x_k = double(subs(d_x,x_derive.',curr_pos));

                        curr_pos = curr_pos + (1e-4)*df_x_k/ norm(df_x_k);

                    end

                    

                    x_newton = fmincon(Func,curr_pos,[],[],[],[],lb,ub);

                end 

            end

        end

    end

    

    

    

    % make sure you're only taking the gradient/ jacobian once!! it will

    % slow you down a lot.

    





    for kk = 1:size(new_soln_bank,2)

       new_soln_bank_obj_values(1,kk) = Func(new_soln_bank(:,kk));

        

    end



    

    

    

    

    if (i==tiers)

        new_soln_bank_obj_values

        prompt = strcat(num2str(total_tiers),' tiers computed.  Input # more tiers to compute, else press enter\n');

        bob = input(prompt);

        if isempty(bob)

            fprintf('ending script\n')

        else

            fprintf('computing %d more tiers\n',bob)

            i = 0;tiers = bob;

        end

    

        

    end

    i = i+1;

    

    

    

    

    

    

    new_solutions_added = size(new_soln_bank,2) - size(old_soln_bank,2);

    old_soln_bank = new_soln_bank;



end





[best_soln,best_i] = min(new_soln_bank_obj_values)

best_x_values = new_soln_bank(:,best_i)









