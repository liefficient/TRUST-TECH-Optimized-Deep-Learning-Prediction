%load weights
layer01_weight=h5read('annmodel.h5','/dense_1/dense_1/kernel:0');
layer01_bias=h5read('annmodel.h5','/dense_1/dense_1/bias:0');
layer12_weight=h5read('annmodel.h5','/dense_2/dense_2/kernel:0');
layer12_bias=h5read('annmodel.h5','/dense_2/dense_2/bias:0');
all_weight=[layer01_weight(:);layer01_bias;layer12_weight(:);layer12_bias];
all_weight=double(all_weight);